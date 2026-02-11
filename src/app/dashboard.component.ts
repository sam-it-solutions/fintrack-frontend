import { Component, OnDestroy, OnInit } from '@angular/core';
import {
  ApiService,
  ProviderResponse,
  ConnectionResponse,
  SummaryResponse,
  AccountResponse,
  TransactionResponse,
  RuleResponse,
  CategoryResponse,
  SavingsGoalResponse,
  RecurringPaymentResponse,
  EnableBankingAspspResponse,
  HouseholdResponse,
  HouseholdBalanceResponse,
  SpendingCategorySummary,
  AdminSettingsResponse,
  AdminSettingsRequest
} from './api.service';
import { SessionService } from './session.service';
import { Subscription, firstValueFrom } from 'rxjs';
import { isPasskeySupported, serializeRegistrationCredential, toPublicKeyCreationOptions } from './webauthn.utils';

type SectionKey = 'overview' | 'accounts' | 'spending' | 'transactions' | 'audit' | 'household' | 'connections' | 'admin';
type ToastType = 'success' | 'error' | 'info';

@Component({
  selector: 'app-dashboard',
  templateUrl: './dashboard.component.html',
  styleUrls: ['./dashboard.component.css']
})
export class DashboardComponent implements OnInit, OnDestroy {
  appName = 'Fintrack';
  subtitle = 'High‑end overzicht van banken en crypto.';

  activeSection: SectionKey = 'overview';
  mobileMoreOpen = false;
  filtersCollapsed = true;

  providers: ProviderResponse[] = [];
  connections: ConnectionResponse[] = [];
  accounts: AccountResponse[] = [];
  transactions: TransactionResponse[] = [];
  cryptoTransactions: TransactionResponse[] = [];
  rules: RuleResponse[] = [];
  goals: SavingsGoalResponse[] = [];
  recurring: RecurringPaymentResponse[] = [];
  householdBalance: HouseholdBalanceResponse | null = null;
  selectedAccountIds: string[] = [];
  labelDrafts: Record<string, string> = {};
  editingAccountId: string | null = null;
  editingCategoryId: string | null = null;
  categoryDrafts: Record<string, string> = {};
  categoryApplyFuture: Record<string, boolean> = {};
  categoryEntities: CategoryResponse[] = [];
  categoryNewName = '';
  categoryEditingId: string | null = null;
  categoryEditDrafts: Record<string, string> = {};
  summary: SummaryResponse | null = null;
  spending: SpendingCategorySummary[] = [];
  households: HouseholdResponse[] = [];
  householdName = '';
  householdInvite = '';
  shareHouseholdId = '';
  manualAccountName = '';
  manualAccountIban = '';
  manualAccountCurrency = 'EUR';
  manualAccountOpeningBalance: string | number = '';
  directionFilter: 'ALL' | 'IN' | 'OUT' = 'ALL';
  transactionQuery = '';
  transactionCategoryFilter = 'ALL';
  transactionsRangeMode: 'MONTH' | 'ALL' = 'MONTH';
  spendingSelectedCategory = 'ALL';
  spendingDirection: 'OUT' | 'IN' = 'OUT';
  spendingTxPage = 1;
  spendingTxPageSize = 5;
  transactionsPage = 1;
  transactionsPageSize = 10;
  auditPage = 1;
  auditPageSize = 10;
  categories: string[] = [];
  readonly defaultCategories = [
    'Boodschappen',
    'Horeca',
    'Transport',
    'Shopping',
    'Abonnementen',
    'Utilities',
    'Huur/Hypotheek',
    'Gezondheid',
    'Onderwijs',
    'Cash',
    'Transfer',
    'Inkomen',
    'Crypto',
    'Overig'
  ];
  readonly ruleMatchTypes = [
    { value: 'MERCHANT', label: 'Merchant / Naam' },
    { value: 'DESCRIPTION', label: 'Beschrijving' },
    { value: 'IBAN', label: 'IBAN' }
  ];
  readonly ruleMatchModes = [
    { value: 'CONTAINS', label: 'Bevat' },
    { value: 'EXACT', label: 'Exact' }
  ];

  selectedProvider: ProviderResponse | null = null;
  connectionName = '';
  connectionConfig: Record<string, string> = {};
  enableBankingAspsps: EnableBankingAspspResponse[] = [];
  enableBankingLoading = false;
  enableBankingQuery = '';
  private _statusMessage = '';
  toasts: Array<{ id: number; message: string; type: ToastType }> = [];
  loading = false;
  recategorizing = false;
  passkeySupported = isPasskeySupported();
  passkeyBusy = false;
  passkeyEnabled = false;
  month = new Date().toISOString().slice(0, 7);
  householdBalanceMonth = new Date().toISOString().slice(0, 7);
  includeSharedBalance = false;
  recurringMonths = 6;
  adminSettings: AdminSettingsResponse | null = null;
  adminSettingsDraft: AdminSettingsRequest = {
    syncEnabled: true,
    syncIntervalMs: 21600000,
    aiEnabled: true,
    aiModel: ''
  };
  adminSaving = false;
  readonly syncIntervalOptions = [
    { label: 'Elke 15 min', value: 15 * 60 * 1000 },
    { label: 'Elke 30 min', value: 30 * 60 * 1000 },
    { label: 'Elke 1 uur', value: 60 * 60 * 1000 },
    { label: 'Elke 3 uur', value: 3 * 60 * 60 * 1000 },
    { label: 'Elke 6 uur', value: 6 * 60 * 60 * 1000 },
    { label: 'Elke 12 uur', value: 12 * 60 * 60 * 1000 },
    { label: 'Elke 24 uur', value: 24 * 60 * 60 * 1000 }
  ];

  ruleMatchType = 'MERCHANT';
  ruleMatchMode: 'CONTAINS' | 'EXACT' = 'CONTAINS';
  ruleMatchValue = '';
  ruleCategory = 'Overig';
  ruleApplyHistory = true;

  selectedCryptoAssetId: string | null = null;

  goalName = '';
  goalTarget = '';
  goalMonthly = '';
  goalCurrency = 'EUR';
  goalAuto = true;
  goalDrafts: Record<string, string> = {};
  goalMonthlyDrafts: Record<string, string> = {};
  goalAutoDrafts: Record<string, boolean> = {};

  private tokenSub?: Subscription;
  private syncPollTimer?: ReturnType<typeof setInterval>;
  private toastSeq = 0;
  private readonly handleFocus = () => {
    if (this.token) {
      this.loadAll();
    }
  };
  private readonly handleVisibility = () => {
    if (!document.hidden && this.token) {
      this.loadAll();
    }
  };

  constructor(private api: ApiService, private session: SessionService) {}

  ngOnInit(): void {
    this.tokenSub = this.session.token$.subscribe((token) => {
      if (token) {
        this.syncPasskeyState();
        this.loadAll();
      } else {
        this.resetState();
        this.passkeyEnabled = false;
      }
    });
    window.addEventListener('focus', this.handleFocus);
    document.addEventListener('visibilitychange', this.handleVisibility);
  }

  ngOnDestroy(): void {
    this.tokenSub?.unsubscribe();
    if (this.syncPollTimer) {
      clearInterval(this.syncPollTimer);
      this.syncPollTimer = undefined;
    }
    window.removeEventListener('focus', this.handleFocus);
    document.removeEventListener('visibilitychange', this.handleVisibility);
  }

  get token(): string | null {
    return this.session.token;
  }

  get statusMessage(): string {
    return this._statusMessage;
  }

  set statusMessage(message: string) {
    this._statusMessage = message;
    if (!message) {
      return;
    }
    this.pushToast(message);
  }

  private getPasskeyStorageKey(): string | null {
    const token = this.token;
    if (!token) {
      return null;
    }
    try {
      const payload = JSON.parse(atob(token.split('.')[1] ?? ''));
      const subject = payload?.sub ?? payload?.email;
      return subject ? `fintrack_passkey_${subject}` : 'fintrack_passkey_enabled';
    } catch {
      return 'fintrack_passkey_enabled';
    }
  }

  private syncPasskeyState(): void {
    const key = this.getPasskeyStorageKey();
    if (!key) {
      this.passkeyEnabled = false;
      return;
    }
    this.passkeyEnabled = localStorage.getItem(key) === '1';
  }

  get filterSummaryLabel(): string {
    const parts: string[] = [];
    if (this.month) {
      parts.push(this.formatMonthLabel(this.month));
    }
    if (this.selectedAccountIds.length > 0) {
      parts.push(`${this.selectedAccountIds.length} rekening${this.selectedAccountIds.length > 1 ? 'en' : ''}`);
    }
    if (this.directionFilter !== 'ALL') {
      parts.push(this.directionFilter === 'IN' ? 'Inkomen' : 'Uitgaven');
    }
    if (this.transactionCategoryFilter && this.transactionCategoryFilter !== 'ALL') {
      parts.push(this.transactionCategoryFilter);
    }
    const query = (this.transactionQuery || '').trim();
    if (query) {
      parts.push(`Zoek: ${query}`);
    }
    return parts.join(' · ') || 'Geen filters actief';
  }

  private formatMonthLabel(month: string): string {
    try {
      const date = new Date(`${month}-01T00:00:00`);
      if (Number.isNaN(date.getTime())) {
        return month;
      }
      return date.toLocaleDateString('nl-BE', { month: 'short', year: 'numeric' });
    } catch {
      return month;
    }
  }

  setSection(section: SectionKey, options?: { preserveTransactionsRange?: boolean }) {
    this.activeSection = section;
    this.statusMessage = '';
    this.mobileMoreOpen = false;
    if (section === 'overview') {
      this.spendingDirection = 'OUT';
    }
    if (section !== 'transactions') {
      this.transactionsRangeMode = 'MONTH';
    } else if (!options?.preserveTransactionsRange) {
      this.transactionsRangeMode = 'MONTH';
      this.loadTransactions();
    }
    if (section === 'audit') {
      this.auditPage = 1;
    }
  }

  openSpendingOverview(direction: 'IN' | 'OUT') {
    this.spendingDirection = direction;
    this.spendingSelectedCategory = 'ALL';
    this.spendingTxPage = 1;
    this.filtersCollapsed = false;
    this.setSection('spending');
  }

  openCryptoDetails(asset: AccountResponse) {
    this.selectedCryptoAssetId = asset.id;
    this.loadCryptoTransactions();
  }

  toggleMobileMore() {
    this.mobileMoreOpen = !this.mobileMoreOpen;
  }

  closeMobileMore() {
    this.mobileMoreOpen = false;
  }

  dismissToast(id: number) {
    this.toasts = this.toasts.filter(toast => toast.id !== id);
  }

  private pushToast(message: string, type?: ToastType) {
    const resolvedType = type ?? this.inferToastType(message);
    const toast = { id: ++this.toastSeq, message, type: resolvedType };
    this.toasts = [...this.toasts, toast].slice(-3);
    setTimeout(() => this.dismissToast(toast.id), 4200);
  }

  private inferToastType(message: string): ToastType {
    const lower = message.toLowerCase();
    const errorHints = ['mislukt', 'kon', 'niet', 'error', 'failed', 'verboden', 'ontbreekt', 'invalid'];
    const successHints = ['opgeslagen', 'toegevoegd', 'bijgewerkt', 'gestart', 'klaar', 'geactiveerd', 'gedeactiveerd', 'verwijderd', 'toegevoegd'];
    if (errorHints.some(hint => lower.includes(hint))) {
      return 'error';
    }
    if (successHints.some(hint => lower.includes(hint))) {
      return 'success';
    }
    return 'info';
  }

  applyCategoryFilter(category: string) {
    this.transactionCategoryFilter = category;
    this.directionFilter = 'OUT';
    this.setSection('transactions');
    this.filtersCollapsed = false;
  }

  setSpendingCategory(category: string) {
    this.spendingSelectedCategory = category;
    this.spendingTxPage = 1;
  }

  clearSpendingCategory() {
    this.spendingSelectedCategory = 'ALL';
    this.spendingTxPage = 1;
  }

  logout() {
    this.session.clear();
  }

  loadAll() {
    if (!this.token) {
      return;
    }
    this.transactionsRangeMode = 'MONTH';
    this.spendingTxPage = 1;
    this.transactionsPage = 1;
    this.auditPage = 1;
    this.householdBalanceMonth = this.month;
    this.loading = true;

    this.api.listProviders(this.token).subscribe({
      next: (providers) => {
        this.providers = providers;
      },
      error: () => this.providers = []
    });

    this.refreshConnections();

    this.api.summary(this.token).subscribe({
      next: (summary) => this.summary = summary,
      error: () => this.summary = null
    });

    this.loadCategories();
    this.loadRules();
    this.loadGoals();
    this.loadRecurring();

    this.api.accounts(this.token).subscribe({
      next: (accounts) => {
        this.accounts = accounts;
        const bankIds = new Set(this.filterableBankAccounts.map((a) => a.id));
        this.selectedAccountIds = this.selectedAccountIds.filter((id) => bankIds.has(id));
      },
      error: () => this.accounts = []
    });

    this.loadTransactions();

    this.api.spending(this.token, this.month).subscribe({
      next: (spending) => this.spending = spending,
      error: () => this.spending = []
    });

    this.api.listHouseholds(this.token).subscribe({
      next: (households) => {
        this.households = households;
        if (!this.shareHouseholdId && households.length > 0) {
          this.shareHouseholdId = households[0].id;
        }
        this.loadHouseholdBalance();
      },
      error: () => this.households = []
    });

    this.loadAdminSettings();

    this.loading = false;
  }

  refresh() {
    this.loadAll();
  }

  async registerPasskey() {
    if (!this.token) {
      return;
    }
    if (!this.passkeySupported) {
      this.statusMessage = 'Face ID is niet beschikbaar op dit toestel.';
      return;
    }
    this.passkeyBusy = true;
    this.statusMessage = '';
    try {
      const start = await firstValueFrom(this.api.passkeyRegisterStart(this.token));
      const publicKey = toPublicKeyCreationOptions(start.options);
      const credential = await navigator.credentials.create({ publicKey }) as PublicKeyCredential | null;
      if (!credential) {
        throw new Error('Geen passkey aangemaakt.');
      }
      const payload = serializeRegistrationCredential(credential);
      await firstValueFrom(this.api.passkeyRegisterFinish(this.token, start.challengeId, payload));
      const key = this.getPasskeyStorageKey();
      if (key) {
        localStorage.setItem(key, '1');
      }
      this.passkeyEnabled = true;
      this.statusMessage = 'Face ID is geactiveerd op dit toestel.';
    } catch (err: any) {
      if (err?.status === 401 || err?.status === 403) {
        this.statusMessage = 'Log opnieuw in om Face ID te activeren.';
      } else {
        this.statusMessage = err?.error?.message ?? err?.message ?? 'Face ID activeren mislukt.';
      }
    } finally {
      this.passkeyBusy = false;
    }
  }

  loadRules() {
    if (!this.token) {
      return;
    }
    this.api.listRules(this.token).subscribe({
      next: (rules) => this.rules = rules,
      error: () => this.rules = []
    });
  }

  loadCategories() {
    if (!this.token) {
      return;
    }
    this.api.listCategories(this.token).subscribe({
      next: (categories) => {
        this.categoryEntities = categories;
        this.refreshCategoryNames();
      },
      error: () => {
        this.categoryEntities = [];
        if (this.categories.length === 0) {
          this.categories = [...this.defaultCategories];
        }
      }
    });
  }

  loadAdminSettings() {
    if (!this.token) {
      return;
    }
    this.api.getAdminSettings(this.token).subscribe({
      next: (settings) => {
        this.adminSettings = settings;
        this.adminSettingsDraft = {
          syncEnabled: settings.syncEnabled,
          syncIntervalMs: settings.syncIntervalMs,
          aiEnabled: settings.aiEnabled,
          aiModel: settings.aiModel ?? ''
        };
      },
      error: () => {
        this.adminSettings = null;
      }
    });
  }

  saveAdminSettings() {
    if (!this.token) {
      return;
    }
    this.adminSaving = true;
    const payload: AdminSettingsRequest = {
      syncEnabled: this.adminSettingsDraft.syncEnabled ?? true,
      syncIntervalMs: Number(this.adminSettingsDraft.syncIntervalMs ?? 21600000),
      aiEnabled: this.adminSettingsDraft.aiEnabled ?? true,
      aiModel: (this.adminSettingsDraft.aiModel ?? '').trim() || null
    };
    this.api.updateAdminSettings(this.token, payload).subscribe({
      next: (settings) => {
        this.adminSettings = settings;
        this.adminSettingsDraft = {
          syncEnabled: settings.syncEnabled,
          syncIntervalMs: settings.syncIntervalMs,
          aiEnabled: settings.aiEnabled,
          aiModel: settings.aiModel ?? ''
        };
        this.statusMessage = 'Instellingen opgeslagen.';
        this.adminSaving = false;
      },
      error: () => {
        this.statusMessage = 'Instellingen opslaan mislukt.';
        this.adminSaving = false;
      }
    });
  }

  loadGoals() {
    if (!this.token) {
      return;
    }
    this.api.listGoals(this.token).subscribe({
      next: (goals) => {
        this.goals = goals;
        this.goalDrafts = {};
        this.goalMonthlyDrafts = {};
        this.goalAutoDrafts = {};
        goals.forEach((goal) => {
          this.goalDrafts[goal.id] = String(goal.currentAmount ?? '');
          this.goalMonthlyDrafts[goal.id] = String(goal.monthlyContribution ?? '');
          this.goalAutoDrafts[goal.id] = goal.autoEnabled;
        });
      },
      error: () => this.goals = []
    });
  }

  loadRecurring() {
    if (!this.token) {
      return;
    }
    this.api.recurringPayments(this.token, this.recurringMonths).subscribe({
      next: (items) => this.recurring = items,
      error: () => this.recurring = []
    });
  }

  loadHouseholdBalance() {
    if (!this.token || !this.shareHouseholdId) {
      this.householdBalance = null;
      return;
    }
    this.api.householdBalance(this.token, this.shareHouseholdId, this.householdBalanceMonth, this.includeSharedBalance).subscribe({
      next: (balance) => this.householdBalance = balance,
      error: () => this.householdBalance = null
    });
  }

  get categoriesAvailable(): string[] {
    return this.categories.length ? this.categories : this.defaultCategories;
  }

  selectProvider(provider: ProviderResponse) {
    this.selectedProvider = provider;
    this.connectionName = '';
    this.connectionConfig = {};
    provider.fields?.forEach((field) => {
      this.connectionConfig[field.key] = '';
    });
    if (this.isEnableBankingSelected() && this.enableBankingAspsps.length === 0) {
      this.loadEnableBankingAspsps();
    }
  }

  loadEnableBankingAspsps() {
    if (!this.token) {
      return;
    }
    const country = this.connectionConfig['aspspCountry'] || 'BE';
    const psuType = this.connectionConfig['psuType'] || 'personal';
    this.enableBankingLoading = true;
    this.api.listEnableBankingAspsps(this.token, country, psuType).subscribe({
      next: (aspsps) => {
        this.enableBankingAspsps = aspsps.sort((a, b) => a.name.localeCompare(b.name));
        this.enableBankingLoading = false;
      },
      error: () => {
        this.enableBankingAspsps = [];
        this.enableBankingLoading = false;
      }
    });
  }

  selectEnableBankingAspsp(name: string) {
    const aspsp = this.enableBankingAspsps.find((item) => item.name === name);
    if (!aspsp) {
      return;
    }
    this.connectionConfig['aspspName'] = aspsp.name;
    this.connectionConfig['aspspCountry'] = aspsp.country;
    if (!this.connectionName) {
      this.connectionName = aspsp.name;
    }
  }

  createConnection() {
    if (!this.token || !this.selectedProvider) {
      return;
    }
    const payload = {
      providerId: this.selectedProvider.id,
      displayName: this.connectionName,
      config: this.connectionConfig
    };
    this.loading = true;
    this.api.createConnection(this.token, payload).subscribe({
      next: () => {
        this.statusMessage = 'Connectie aangemaakt.';
        this.selectedProvider = null;
        this.connectionName = '';
        this.connectionConfig = {};
        this.loadAll();
      },
      error: (err) => {
        this.loading = false;
        this.statusMessage = err?.error?.message ?? 'Kon connectie niet aanmaken.';
      }
    });
  }

  initiateConnection(connection: ConnectionResponse) {
    if (!this.token) {
      return;
    }
    this.api.initiateConnection(this.token, connection.id).subscribe({
      next: (res) => {
        if (res?.url) {
          window.open(res.url, '_blank');
        }
        this.statusMessage = 'Bank flow gestart. Rond af in het nieuwe venster.';
      },
      error: (err) => {
        this.statusMessage = err?.error?.message ?? 'Kan connectie niet starten.';
      }
    });
  }

  syncConnection(connection: ConnectionResponse) {
    if (!this.token) {
      return;
    }
    this.statusMessage = 'Sync gestart. We updaten de status...';
    this.api.syncConnection(this.token, connection.id).subscribe({
      next: (updated) => {
        this.connections = this.connections.map((item) => item.id === updated.id ? updated : item);
        this.updateSyncPolling();
        this.statusMessage = updated.syncStatus === 'RUNNING'
          ? 'Sync bezig. Even geduld.'
          : 'Sync aangevraagd.';
      },
      error: (err) => {
        this.statusMessage = err?.error?.message ?? 'Sync mislukt.';
      }
    });
  }

  refreshConnections() {
    if (!this.token) {
      return;
    }
    this.api.listConnections(this.token).subscribe({
      next: (connections) => {
        this.connections = connections;
        this.updateSyncPolling();
      },
      error: () => this.connections = []
    });
  }

  private updateSyncPolling() {
    const hasRunning = this.connections.some((connection) => connection.syncStatus === 'RUNNING');
    if (hasRunning && !this.syncPollTimer) {
      this.syncPollTimer = setInterval(() => this.refreshConnections(), 4000);
    }
    if (!hasRunning && this.syncPollTimer) {
      clearInterval(this.syncPollTimer);
      this.syncPollTimer = undefined;
    }
  }

  syncStatusLabel(status?: string) {
    switch ((status ?? '').toUpperCase()) {
      case 'RUNNING':
        return 'Sync bezig';
      case 'SUCCESS':
        return 'Sync klaar';
      case 'FAILED':
        return 'Sync mislukt';
      case 'SKIPPED':
        return 'Sync overgeslagen';
      default:
        return 'Sync idle';
    }
  }

  syncStatusClass(status?: string) {
    switch ((status ?? '').toUpperCase()) {
      case 'RUNNING':
        return 'sync-pill sync-running';
      case 'SUCCESS':
        return 'sync-pill sync-success';
      case 'FAILED':
        return 'sync-pill sync-failed';
      case 'SKIPPED':
        return 'sync-pill sync-skipped';
      default:
        return 'sync-pill sync-idle';
    }
  }

  toggleAutoSync(connection: ConnectionResponse) {
    if (!this.token) {
      return;
    }
    this.api.updateConnection(this.token, connection.id, {
      autoSyncEnabled: !connection.autoSyncEnabled
    }).subscribe({
      next: () => this.loadAll()
    });
  }

  disableConnection(connection: ConnectionResponse) {
    if (!this.token) {
      return;
    }
    this.api.deleteConnection(this.token, connection.id).subscribe({
      next: () => {
        this.statusMessage = 'Connectie gedeactiveerd.';
        this.loadAll();
      }
    });
  }

  createHousehold() {
    if (!this.token || !this.householdName) {
      return;
    }
    this.api.createHousehold(this.token, this.householdName).subscribe({
      next: () => {
        this.statusMessage = 'Gezamenlijke ruimte aangemaakt.';
        this.householdName = '';
        this.loadAll();
      },
      error: (err) => {
        this.statusMessage = err?.error?.message ?? 'Kon household niet aanmaken.';
      }
    });
  }

  joinHousehold() {
    if (!this.token || !this.householdInvite) {
      return;
    }
    this.api.joinHousehold(this.token, this.householdInvite).subscribe({
      next: () => {
        this.statusMessage = 'Je bent toegevoegd aan de gezamenlijke ruimte.';
        this.householdInvite = '';
        this.loadAll();
      },
      error: (err) => {
        this.statusMessage = err?.error?.message ?? 'Kon niet deelnemen.';
      }
    });
  }

  shareAccount(account: AccountResponse) {
    if (!this.token || !this.shareHouseholdId) {
      return;
    }
    this.api.shareAccount(this.token, account.id, this.shareHouseholdId).subscribe({
      next: () => {
        this.statusMessage = 'Account gedeeld met household.';
        this.loadAll();
      },
      error: (err) => {
        this.statusMessage = err?.error?.message ?? 'Delen mislukt.';
      }
    });
  }

  recategorizeAll() {
    if (!this.token || this.recategorizing) {
      return;
    }
    this.recategorizing = true;
    this.api.recategorizeAll(this.token).subscribe({
      next: (res) => {
        this.statusMessage = `AI categorieen bijgewerkt (${res.updatedCount}/${res.totalCount}).`;
        this.recategorizing = false;
        this.loadAll();
      },
      error: (err) => {
        this.recategorizing = false;
        this.statusMessage = err?.error?.message ?? 'Recategorize mislukt.';
      }
    });
  }

  createRule() {
    if (!this.token) {
      return;
    }
    if (!this.ruleMatchValue.trim()) {
      this.statusMessage = 'Vul een match waarde in.';
      return;
    }
    if (this.ruleMatchType === 'IBAN') {
      this.ruleMatchMode = 'EXACT';
    }
    const payload = {
      matchType: this.ruleMatchType,
      matchMode: this.ruleMatchMode,
      matchValue: this.ruleMatchValue.trim(),
      category: this.ruleCategory
    };
    this.api.createRule(this.token, payload).subscribe({
      next: (created) => {
        this.rules = [created, ...this.rules];
        this.statusMessage = 'Smart rule opgeslagen.';
        this.ruleMatchValue = '';
        if (this.ruleApplyHistory) {
          this.applyRuleHistory(created);
        }
      },
      error: (err) => {
        this.statusMessage = err?.error?.message ?? 'Kon rule niet opslaan.';
      }
    });
  }

  onRuleMatchTypeChange() {
    if (this.ruleMatchType === 'IBAN') {
      this.ruleMatchMode = 'EXACT';
      return;
    }
    if (this.ruleMatchMode !== 'CONTAINS' && this.ruleMatchMode !== 'EXACT') {
      this.ruleMatchMode = 'CONTAINS';
    }
  }

  createCategory() {
    if (!this.token) {
      return;
    }
    const name = this.categoryNewName.trim();
    if (!name) {
      this.statusMessage = 'Vul een categorienaam in.';
      return;
    }
    this.api.createCategory(this.token, { name }).subscribe({
      next: (created) => {
        this.categoryEntities = [created, ...this.categoryEntities];
        this.categoryNewName = '';
        this.refreshCategoryNames();
      },
      error: (err) => {
        this.statusMessage = err?.error?.message ?? 'Kon categorie niet toevoegen.';
      }
    });
  }

  startEditCategoryEntity(category: CategoryResponse) {
    this.categoryEditingId = category.id;
    this.categoryEditDrafts[category.id] = category.name;
  }

  cancelEditCategoryEntity() {
    this.categoryEditingId = null;
  }

  saveCategoryEntity(category: CategoryResponse) {
    if (!this.token) {
      return;
    }
    const name = (this.categoryEditDrafts[category.id] || '').trim();
    if (!name) {
      this.statusMessage = 'Categorie naam is verplicht.';
      return;
    }
    this.api.updateCategory(this.token, category.id, { name }).subscribe({
      next: (updated) => {
        this.categoryEntities = this.categoryEntities.map((item) => item.id === updated.id ? updated : item);
        this.categoryEditingId = null;
        this.refreshCategoryNames();
      },
      error: (err) => {
        this.statusMessage = err?.error?.message ?? 'Kon categorie niet bijwerken.';
      }
    });
  }

  deleteCategoryEntity(category: CategoryResponse) {
    if (!this.token) {
      return;
    }
    if (!window.confirm(`Categorie \"${category.name}\" verwijderen?`)) {
      return;
    }
    this.api.deleteCategory(this.token, category.id).subscribe({
      next: () => {
        this.categoryEntities = this.categoryEntities.filter((item) => item.id !== category.id);
        this.refreshCategoryNames();
      },
      error: (err) => {
        this.statusMessage = err?.error?.message ?? 'Kon categorie niet verwijderen.';
      }
    });
  }

  deleteRule(rule: RuleResponse) {
    if (!this.token) {
      return;
    }
    if (!window.confirm(`Rule voor ${rule.matchValue} verwijderen?`)) {
      return;
    }
    this.api.deleteRule(this.token, rule.id).subscribe({
      next: () => {
        this.rules = this.rules.filter((item) => item.id !== rule.id);
        this.statusMessage = 'Rule verwijderd.';
      },
      error: (err) => {
        this.statusMessage = err?.error?.message ?? 'Kon rule niet verwijderen.';
      }
    });
  }

  applyRuleHistory(rule: RuleResponse) {
    if (!this.token) {
      return;
    }
    this.api.applyRuleToHistory(this.token, rule.id).subscribe({
      next: (res) => {
        this.statusMessage = `Rule toegepast op geschiedenis (${res.updatedCount}/${res.totalCount}).`;
        this.loadTransactions();
      },
      error: (err) => {
        this.statusMessage = err?.error?.message ?? 'Rule toepassen mislukt.';
      }
    });
  }

  createGoal() {
    if (!this.token) {
      return;
    }
    if (!this.goalName.trim()) {
      this.statusMessage = 'Vul een naam in voor je spaarpot.';
      return;
    }
    const target = this.parseNumber(this.goalTarget);
    if (target === null) {
      this.statusMessage = 'Vul een geldig doelbedrag in.';
      return;
    }
    const payload = {
      name: this.goalName.trim(),
      currency: this.goalCurrency,
      targetAmount: target,
      monthlyContribution: this.parseNumber(this.goalMonthly),
      autoEnabled: this.goalAuto
    };
    this.api.createGoal(this.token, payload).subscribe({
      next: (created) => {
        this.statusMessage = 'Spaarpot toegevoegd.';
        this.goals = [created, ...this.goals];
        this.goalName = '';
        this.goalTarget = '';
        this.goalMonthly = '';
        this.goalAuto = true;
        this.loadGoals();
      },
      error: (err) => {
        this.statusMessage = err?.error?.message ?? 'Kon spaarpot niet toevoegen.';
      }
    });
  }

  updateGoal(goal: SavingsGoalResponse) {
    if (!this.token) {
      return;
    }
    const currentAmount = this.parseNumber(this.goalDrafts[goal.id]);
    const monthly = this.parseNumber(this.goalMonthlyDrafts[goal.id]);
    const payload: any = {
      currentAmount,
      monthlyContribution: monthly,
      autoEnabled: this.goalAutoDrafts[goal.id]
    };
    this.api.updateGoal(this.token, goal.id, payload).subscribe({
      next: (updated) => {
        this.goals = this.goals.map((item) => item.id === updated.id ? updated : item);
        this.statusMessage = 'Spaarpot bijgewerkt.';
      },
      error: (err) => {
        this.statusMessage = err?.error?.message ?? 'Kon spaarpot niet bijwerken.';
      }
    });
  }

  deleteGoal(goal: SavingsGoalResponse) {
    if (!this.token) {
      return;
    }
    if (!window.confirm(`Spaarpot "${goal.name}" verwijderen?`)) {
      return;
    }
    this.api.deleteGoal(this.token, goal.id).subscribe({
      next: () => {
        this.goals = this.goals.filter((item) => item.id !== goal.id);
        this.statusMessage = 'Spaarpot verwijderd.';
      },
      error: (err) => {
        this.statusMessage = err?.error?.message ?? 'Kon spaarpot niet verwijderen.';
      }
    });
  }

  isTinkSelected(): boolean {
    return this.selectedProvider?.id === 'tink';
  }

  isEnableBankingSelected(): boolean {
    return this.selectedProvider?.id === 'enablebanking';
  }

  get filteredEnableBankingAspsps(): EnableBankingAspspResponse[] {
    const query = this.enableBankingQuery.trim().toLowerCase();
    if (!query) {
      return this.enableBankingAspsps.slice(0, 50);
    }
    return this.enableBankingAspsps
      .filter((item) => item.name.toLowerCase().includes(query))
      .slice(0, 50);
  }

  get bankAccounts(): AccountResponse[] {
    return this.accounts.filter((a) => a.type === 'BANK');
  }

  get filterableBankAccounts(): AccountResponse[] {
    return this.bankAccounts.filter((a) => !this.isManualAccount(a));
  }

  get cryptoAccounts(): AccountResponse[] {
    return this.accounts.filter((a) => a.type === 'CRYPTO');
  }

  isManualAccount(account: AccountResponse): boolean {
    return !account.connectionId && (account.provider || '').toLowerCase() === 'manual';
  }

  get cryptoWallets(): {
    id: string;
    name: string;
    provider: string;
    assets: AccountResponse[];
    totalFiatValue: number;
  }[] {
    const wallets = new Map<string, {
      id: string;
      name: string;
      provider: string;
      assets: AccountResponse[];
      totalFiatValue: number;
    }>();
    for (const account of this.cryptoAccounts) {
      const key = account.connectionId ?? account.provider ?? account.id;
      const existing = wallets.get(key);
      if (!existing) {
        const connection = account.connectionId
          ? this.connections.find((c) => c.id === account.connectionId)
          : null;
        const name = connection?.displayName ?? account.provider ?? 'Crypto wallet';
        const provider = account.provider ?? 'Crypto';
        wallets.set(key, {
          id: key,
          name,
          provider,
          assets: [account],
          totalFiatValue: account.currentFiatValue ?? 0
        });
      } else {
        existing.assets.push(account);
        existing.totalFiatValue += account.currentFiatValue ?? 0;
      }
    }
    return Array.from(wallets.values())
      .map((wallet) => ({
        ...wallet,
        assets: [...wallet.assets].sort((a, b) => (b.currentFiatValue ?? 0) - (a.currentFiatValue ?? 0))
      }))
      .sort((a, b) => b.totalFiatValue - a.totalFiatValue);
  }

  get hasAccountFilter(): boolean {
    return this.selectedAccountIds.length > 0;
  }

  get hasHouseholds(): boolean {
    return this.households.length > 0;
  }

  spendingByCurrency(currency: string): SpendingCategorySummary[] {
    return this.spendingSource
      .filter((s) => s.currency === currency)
      .sort((a, b) => b.total - a.total);
  }

  get spendingCurrencies(): string[] {
    return Array.from(new Set(this.spendingSource.map((s) => s.currency)));
  }

  maxSpending(currency: string): number {
    const items = this.spendingByCurrency(currency);
    return items.length ? Math.max(...items.map((i) => i.total)) : 0;
  }

  accountLabel(accountId: string): string {
    const account = this.accounts.find((a) => a.id === accountId);
    if (!account) {
      return 'Rekening';
    }
    return `${this.accountDisplayName(account)} · ${account.provider}`;
  }

  accountDisplayName(account: AccountResponse): string {
    return (account.label && account.label.trim().length > 0) ? account.label : account.name;
  }

  get primarySummary() {
    if (!this.summary?.summaries?.length) {
      return null;
    }
    return this.summary.summaries.find((s) => s.currency === 'EUR') ?? this.summary.summaries[0];
  }

  get primaryCurrency(): string {
    return this.primarySummary?.currency ?? 'EUR';
  }

  get totalBalance(): number {
    return this.primarySummary?.totalBalance ?? 0;
  }

  get totalIncomeMonth(): number {
    return this.filteredMonthTotals.income;
  }

  get totalExpenseMonth(): number {
    return this.filteredMonthTotals.expense;
  }

  get spendingDirectionLabel(): string {
    return this.spendingDirection === 'OUT' ? 'Uitgaven' : 'Inkomsten';
  }

  get spendingDirectionAmount(): number {
    return this.spendingDirection === 'OUT' ? this.totalExpenseMonth : this.totalIncomeMonth;
  }

  get averageDailySpend(): number {
    return this.averageDailyAmountFor(this.totalExpenseMonth);
  }

  get averageDailyIncome(): number {
    return this.averageDailyAmountFor(this.totalIncomeMonth);
  }

  get averageDailyAmount(): number {
    return this.spendingDirection === 'OUT' ? this.averageDailySpend : this.averageDailyIncome;
  }

  get netMonth(): number {
    return this.totalIncomeMonth - this.totalExpenseMonth;
  }

  private averageDailyAmountFor(total: number): number {
    const [yearStr, monthStr] = (this.month || '').split('-');
    const year = Number(yearStr);
    const monthIndex = Number(monthStr) - 1;
    const isValidMonth = Number.isFinite(year) && Number.isFinite(monthIndex) && monthIndex >= 0 && monthIndex <= 11;
    const now = new Date();
    const isCurrentMonth = isValidMonth
      && now.getFullYear() === year
      && now.getMonth() === monthIndex;
    const days = isValidMonth
      ? (isCurrentMonth ? now.getDate() : new Date(year, monthIndex + 1, 0).getDate())
      : 30;
    return days > 0 ? total / days : total;
  }

  get netWorthEur(): number {
    return this.bankTotalEur + this.cryptoFiatTotal;
  }

  get netWorthTrendSeries(): number[] {
    return this.buildNetWorthSeries(30);
  }

  get netWorthMin(): number {
    const series = this.netWorthTrendSeries;
    return series.length ? Math.min(...series) : 0;
  }

  get netWorthMax(): number {
    const series = this.netWorthTrendSeries;
    return series.length ? Math.max(...series) : 0;
  }

  get netWorthTrendPoints(): string {
    return this.buildSparkline(this.netWorthTrendSeries, 240, 80);
  }

  get netWorthTrendAreaPoints(): string {
    return this.buildSparklineArea(this.netWorthTrendSeries, 240, 80);
  }

  get netWorthTrendDelta(): number {
    const series = this.netWorthTrendSeries;
    if (series.length < 2) {
      return 0;
    }
    return series[series.length - 1] - series[0];
  }

  get netWorthTrendDeltaPct(): number {
    const series = this.netWorthTrendSeries;
    if (series.length < 2) {
      return 0;
    }
    const base = Math.abs(series[0]) || 1;
    return ((series[series.length - 1] - series[0]) / base) * 100;
  }

  get dailySeries() {
    return this.buildDailySeries(14, this.filteredTransactions);
  }

  get expenseSeries14(): number[] {
    return this.dailySeries.expense;
  }

  get incomeSeries14(): number[] {
    return this.dailySeries.income;
  }

  get expenseTotal14(): number {
    return this.expenseSeries14.reduce((acc, value) => acc + value, 0);
  }

  get incomeTotal14(): number {
    return this.incomeSeries14.reduce((acc, value) => acc + value, 0);
  }

  get expenseMax14(): number {
    return Math.max(...this.expenseSeries14, 0);
  }

  get incomeMax14(): number {
    return Math.max(...this.incomeSeries14, 0);
  }

  get expenseAvg14(): number {
    return this.expenseSeries14.length ? this.expenseTotal14 / this.expenseSeries14.length : 0;
  }

  get cashflowSeries(): number[] {
    return this.incomeSeries14.map((value, index) => value - (this.expenseSeries14[index] ?? 0));
  }

  get cashflowSparklinePoints(): string {
    return this.buildSparkline(this.cashflowSeries, 240, 80);
  }

  get cashflowTotal14(): number {
    return this.cashflowSeries.reduce((acc, value) => acc + value, 0);
  }

  get cashflowAvg14(): number {
    return this.cashflowSeries.length ? this.cashflowTotal14 / this.cashflowSeries.length : 0;
  }

  get expenseSparklinePoints(): string {
    return this.buildSparkline(this.expenseSeries14, 240, 80);
  }

  get expenseSparklineAreaPoints(): string {
    return this.buildSparklineArea(this.expenseSeries14, 240, 80);
  }

  get incomeSparklinePoints(): string {
    return this.buildSparkline(this.incomeSeries14, 240, 80);
  }

  get bankTotalEur(): number {
    return this.bankAccounts
      .filter((a) => (a.currency || '').toUpperCase() === 'EUR')
      .map((a) => a.currentBalance ?? 0)
      .reduce((acc, value) => acc + value, 0);
  }

  get totalSpendingEur(): number {
    return this.spendingSource
      .filter((s) => (s.currency || '').toUpperCase() === 'EUR')
      .map((s) => s.total ?? 0)
      .reduce((acc, value) => acc + value, 0);
  }

  get topSpendingItems(): SpendingCategorySummary[] {
    const currency = (this.primaryCurrency || 'EUR').toUpperCase();
    const items = this.spendingSource
      .filter((s) => (s.currency || '').toUpperCase() === currency)
      .sort((a, b) => b.total - a.total);
    return items.slice(0, 6);
  }

  get spendingCategoryList(): SpendingCategorySummary[] {
    const currency = (this.primaryCurrency || 'EUR').toUpperCase();
    return this.spendingSource
      .filter((s) => (s.currency || '').toUpperCase() === currency)
      .sort((a, b) => b.total - a.total);
  }

  get spendingCategoryTotal(): number {
    return this.spendingCategoryList.reduce((acc, item) => acc + (item.total ?? 0), 0);
  }

  get spendingSelectedTotal(): number {
    if (this.spendingSelectedCategory === 'ALL') {
      return this.spendingCategoryTotal;
    }
    const match = this.spendingCategoryList.find((item) => item.category === this.spendingSelectedCategory);
    return match ? match.total : 0;
  }

  get topMerchants(): { name: string; total: number; count: number }[] {
    const out = this.filteredTransactions.filter((t) => t.direction === 'OUT');
    const map = new Map<string, { total: number; count: number }>();
    for (const tx of out) {
      const name = (tx.merchantName || tx.description || 'Onbekend').trim();
      const entry = map.get(name) ?? { total: 0, count: 0 };
      entry.total += Math.abs(tx.amount ?? 0);
      entry.count += 1;
      map.set(name, entry);
    }
    return Array.from(map.entries())
      .map(([name, value]) => ({ name, total: value.total, count: value.count }))
      .sort((a, b) => b.total - a.total)
      .slice(0, 6);
  }

  goalProgress(goal: SavingsGoalResponse): number {
    if (!goal.targetAmount || goal.targetAmount <= 0) {
      return 0;
    }
    const current = goal.currentAmount ?? 0;
    const pct = (current / goal.targetAmount) * 100;
    return Math.max(0, Math.min(100, pct));
  }

  get recentTransactions(): TransactionResponse[] {
    return [...this.filteredTransactions]
      .sort((a, b) => (b.bookingDate ?? '').localeCompare(a.bookingDate ?? ''))
      .slice(0, 6);
  }

  get filteredTransactions(): TransactionResponse[] {
    let result = this.transactions;
    if (this.selectedAccountIds.length) {
      const selected = new Set(this.selectedAccountIds);
      result = result.filter((t) => selected.has(t.accountId));
    }
    if (this.directionFilter !== 'ALL') {
      result = result.filter((t) => t.direction === this.directionFilter);
    }
    if (this.transactionCategoryFilter !== 'ALL') {
      result = result.filter((t) => (t.category || 'Overig') === this.transactionCategoryFilter);
    }
    if (this.transactionQuery.trim().length > 0) {
      const query = this.transactionQuery.trim().toLowerCase();
      result = result.filter((t) => {
        const haystack = [
          t.merchantName,
          t.description,
          t.category,
          this.accountLabel(t.accountId)
        ]
          .filter(Boolean)
          .join(' ')
          .toLowerCase();
        return haystack.includes(query);
      });
    }
    return [...result].sort((a, b) => {
      const aDate = a.bookingDate || a.valueDate || '';
      const bDate = b.bookingDate || b.valueDate || '';
      return bDate.localeCompare(aDate);
    });
  }

  get spendingCategoryTransactions(): TransactionResponse[] {
    let result = this.transactions;
    if (this.selectedAccountIds.length) {
      const selected = new Set(this.selectedAccountIds);
      result = result.filter((t) => selected.has(t.accountId));
    }
    result = this.filterTransactionsByMonth(result, this.month);
    result = result.filter((t) => t.direction === this.spendingDirection);
    if (this.spendingSelectedCategory !== 'ALL') {
      result = result.filter((t) => (t.category || 'Overig') === this.spendingSelectedCategory);
    }
    if (this.transactionQuery.trim().length > 0) {
      const query = this.transactionQuery.trim().toLowerCase();
      result = result.filter((t) => {
        const haystack = [
          t.merchantName,
          t.description,
          t.category,
          this.accountLabel(t.accountId)
        ]
          .filter(Boolean)
          .join(' ')
          .toLowerCase();
        return haystack.includes(query);
      });
    }
    return [...result].sort((a, b) => {
      const aDate = a.bookingDate || a.valueDate || '';
      const bDate = b.bookingDate || b.valueDate || '';
      return bDate.localeCompare(aDate);
    });
  }

  get transactionsTotalPages(): number {
    return Math.max(1, Math.ceil(this.filteredTransactions.length / this.transactionsPageSize));
  }

  get transactionsPageItems(): TransactionResponse[] {
    const totalPages = this.transactionsTotalPages;
    if (this.transactionsPage > totalPages) {
      this.transactionsPage = totalPages;
    }
    const start = (this.transactionsPage - 1) * this.transactionsPageSize;
    return this.filteredTransactions.slice(start, start + this.transactionsPageSize);
  }

  prevTransactionsPage() {
    this.transactionsPage = Math.max(1, this.transactionsPage - 1);
  }

  nextTransactionsPage() {
    this.transactionsPage = Math.min(this.transactionsTotalPages, this.transactionsPage + 1);
  }

  get spendingTxTotalPages(): number {
    return Math.max(1, Math.ceil(this.spendingCategoryTransactions.length / this.spendingTxPageSize));
  }

  get spendingCategoryPageTransactions(): TransactionResponse[] {
    const totalPages = this.spendingTxTotalPages;
    if (this.spendingTxPage > totalPages) {
      this.spendingTxPage = totalPages;
    }
    const start = (this.spendingTxPage - 1) * this.spendingTxPageSize;
    return this.spendingCategoryTransactions.slice(start, start + this.spendingTxPageSize);
  }

  prevSpendingPage() {
    this.spendingTxPage = Math.max(1, this.spendingTxPage - 1);
  }

  nextSpendingPage() {
    this.spendingTxPage = Math.min(this.spendingTxTotalPages, this.spendingTxPage + 1);
  }

  get filteredTransactionsForMonth(): TransactionResponse[] {
    return this.filterTransactionsByMonth(this.filteredTransactions, this.month);
  }

  get spendingSource(): SpendingCategorySummary[] {
    if (this.spendingDirection === 'OUT') {
      if (!this.hasAccountFilter) {
        return this.spending;
      }
      return this.buildCategoryTotals(this.filteredTransactionsForMonth, 'OUT');
    }
    return this.buildCategoryTotals(this.filteredTransactionsForMonth, 'IN');
  }

  get filteredMonthTotals(): { income: number; expense: number } {
    const totals = { income: 0, expense: 0 };
    for (const t of this.filteredTransactionsForMonth) {
      if (this.isNonCashflowCategory(t.category)) {
        continue;
      }
      const amount = Math.abs(t.amount ?? 0);
      if (t.direction === 'IN') {
        totals.income += amount;
      } else if (t.direction === 'OUT') {
        totals.expense += amount;
      }
    }
    return totals;
  }

  get largestExpense(): TransactionResponse | null {
    const out = this.filteredTransactions.filter((t) => t.direction === 'OUT');
    if (!out.length) {
      return null;
    }
    return out.sort((a, b) => Math.abs(b.amount ?? 0) - Math.abs(a.amount ?? 0))[0];
  }

  get bankAccountsPreview(): AccountResponse[] {
    return this.bankAccounts.slice(0, 4);
  }

  get cryptoAccountsPreview(): AccountResponse[] {
    return this.cryptoAccounts.slice(0, 4);
  }

  get cryptoFiatTotal(): number {
    return this.accounts
      .filter((a) => a.type === 'CRYPTO')
      .map((a) => a.currentFiatValue ?? 0)
      .reduce((acc, value) => acc + value, 0);
  }

  get cryptoSnapshotAssets(): AccountResponse[] {
    return [...this.cryptoAccounts]
      .sort((a, b) => (b.currentFiatValue ?? 0) - (a.currentFiatValue ?? 0))
      .slice(0, 6);
  }

  get selectedCryptoAccount(): AccountResponse | null {
    if (!this.selectedCryptoAssetId) {
      return null;
    }
    const account = this.accounts.find((a) => a.id === this.selectedCryptoAssetId);
    return account && account.type === 'CRYPTO' ? account : null;
  }

  selectedAccountLabel(): string {
    if (!this.selectedAccountIds.length) {
      return '';
    }
    if (this.selectedAccountIds.length === 1) {
      return this.accountLabel(this.selectedAccountIds[0]);
    }
    return `${this.selectedAccountIds.length} rekeningen`;
  }

  cryptoUnitPrice(asset: AccountResponse): number {
    const balance = asset.currentBalance ?? 0;
    if (!balance) {
      return 0;
    }
    return (asset.currentFiatValue ?? 0) / balance;
  }

  get cryptoDetailTransactions(): TransactionResponse[] {
    if (!this.selectedCryptoAssetId) {
      return [];
    }
    const source = this.cryptoTransactions.length ? this.cryptoTransactions : this.transactions;
    return source
      .filter((t) => t.accountId === this.selectedCryptoAssetId)
      .sort((a, b) => (b.bookingDate || b.valueDate || '').localeCompare(a.bookingDate || a.valueDate || ''))
      .slice(0, 6);
  }

  get auditTransactions(): TransactionResponse[] {
    return [...this.filteredTransactions]
      .sort((a, b) => (b.bookingDate ?? '').localeCompare(a.bookingDate ?? ''));
  }

  get auditTotalPages(): number {
    return Math.max(1, Math.ceil(this.auditTransactions.length / this.auditPageSize));
  }

  get auditPageItems(): TransactionResponse[] {
    const totalPages = this.auditTotalPages;
    if (this.auditPage > totalPages) {
      this.auditPage = totalPages;
    }
    const start = (this.auditPage - 1) * this.auditPageSize;
    return this.auditTransactions.slice(start, start + this.auditPageSize);
  }

  prevAuditPage() {
    this.auditPage = Math.max(1, this.auditPage - 1);
  }

  nextAuditPage() {
    this.auditPage = Math.min(this.auditTotalPages, this.auditPage + 1);
  }

  get householdSettlements(): { from: string; to: string; amount: number }[] {
    if (!this.householdBalance) {
      return [];
    }
    const creditors = this.householdBalance.members
      .filter((m) => m.balance > 0.01)
      .map((m) => ({ name: m.email || 'Member', amount: m.balance }));
    const debtors = this.householdBalance.members
      .filter((m) => m.balance < -0.01)
      .map((m) => ({ name: m.email || 'Member', amount: -m.balance }));
    const transfers: { from: string; to: string; amount: number }[] = [];
    let i = 0;
    let j = 0;
    while (i < debtors.length && j < creditors.length) {
      const debtor = debtors[i];
      const creditor = creditors[j];
      const amount = Math.min(debtor.amount, creditor.amount);
      if (amount > 0.01) {
        transfers.push({ from: debtor.name, to: creditor.name, amount });
      }
      debtor.amount -= amount;
      creditor.amount -= amount;
      if (debtor.amount <= 0.01) {
        i += 1;
      }
      if (creditor.amount <= 0.01) {
        j += 1;
      }
    }
    return transfers;
  }

  get spendingBars() {
    const series = this.dailySeries.expense;
    const labels = this.dailySeries.labels;
    const max = Math.max(...series, 1);
    return series.map((value, index) => ({
      value,
      label: labels[index],
      height: Math.round((value / max) * 100)
    }));
  }

  formatConfidence(value?: number): string {
    if (value === null || value === undefined) {
      return 'n/a';
    }
    return `${Math.round(value * 100)}%`;
  }

  get netSparklinePoints(): string {
    return this.buildSparkline(this.netSeries, 240, 80);
  }

  get netSparklineAreaPoints(): string {
    return this.buildSparklineArea(this.netSeries, 240, 80);
  }

  get netSparklineLastPoint(): { x: number; y: number } | null {
    const series = this.netSeries;
    if (!series.length) {
      return null;
    }
    return this.sparklinePoint(series, 240, 80, series.length - 1);
  }

  get bankSharePct(): number {
    const total = this.netWorthEur || 0;
    if (!total) {
      return 0;
    }
    return Math.max(0, Math.min(100, (this.bankTotalEur / total) * 100));
  }

  get cryptoSharePct(): number {
    const total = this.netWorthEur || 0;
    if (!total) {
      return 0;
    }
    return Math.max(0, Math.min(100, (this.cryptoFiatTotal / total) * 100));
  }

  get netSeries(): number[] {
    const series = this.dailySeries;
    return series.income.map((value, index) => value - series.expense[index]);
  }

  private sparklinePoint(values: number[], width: number, height: number, index: number) {
    const safeIndex = Math.max(0, Math.min(values.length - 1, index));
    if (!values.length) {
      return null;
    }
    if (values.length === 1) {
      return { x: 0, y: height / 2 };
    }
    const min = Math.min(...values);
    const max = Math.max(...values);
    const range = max - min || 1;
    const x = (safeIndex / (values.length - 1)) * width;
    const y = height - ((values[safeIndex] - min) / range) * height;
    return { x, y };
  }

  private buildSparkline(values: number[], width: number, height: number): string {
    if (!values.length) {
      return '';
    }
    if (values.length === 1) {
      const y = height / 2;
      return `0,${y} ${width},${y}`;
    }
    const min = Math.min(...values);
    const max = Math.max(...values);
    const range = max - min || 1;
    return values
      .map((v, i) => {
        const x = (i / (values.length - 1)) * width;
        const y = height - ((v - min) / range) * height;
        return `${x.toFixed(1)},${y.toFixed(1)}`;
      })
      .join(' ');
  }

  private buildSparklineArea(values: number[], width: number, height: number): string {
    const line = this.buildSparkline(values, width, height);
    if (!line) {
      return '';
    }
    return `0,${height} ${line} ${width},${height}`;
  }

  private buildNetWorthSeries(days: number): number[] {
    const series = this.buildDailySeries(days, this.filteredTransactions);
    const net = series.income.map((income, index) => income - series.expense[index]);
    const totalNet = net.reduce((acc, value) => acc + value, 0);
    let running = this.netWorthEur - totalNet;
    return net.map((value) => {
      running += value;
      return Number(running.toFixed(2));
    });
  }

  private buildDailySeries(days: number, transactions: TransactionResponse[]) {
    const today = new Date();
    const start = new Date();
    start.setDate(today.getDate() - (days - 1));
    const income = new Array(days).fill(0);
    const expense = new Array(days).fill(0);
    const labels = new Array(days).fill('').map((_, index) => {
      const date = new Date(start);
      date.setDate(start.getDate() + index);
      return String(date.getDate()).padStart(2, '0');
    });

    for (const t of transactions) {
      if (!t.bookingDate) {
        continue;
      }
      const date = new Date(t.bookingDate);
      if (Number.isNaN(date.getTime())) {
        continue;
      }
      if (date < start || date > today) {
        continue;
      }
      const idx = Math.floor((date.getTime() - start.getTime()) / 86400000);
      if (idx < 0 || idx >= days) {
        continue;
      }
      if (t.direction === 'IN') {
        income[idx] += Math.abs(t.amount ?? 0);
      } else {
        expense[idx] += Math.abs(t.amount ?? 0);
      }
    }

    return { income, expense, labels };
  }

  cryptoIconUrl(symbol: string): string {
    const code = (symbol || '').toLowerCase();
    if (!code) {
      return this.cryptoIconFallback('??');
    }
    return `https://assets.coincap.io/assets/icons/${code}@2x.png`;
  }

  onCoinIconError(event: Event, symbol: string) {
    const img = event.target as HTMLImageElement | null;
    if (!img) {
      return;
    }
    img.onerror = null;
    img.src = this.cryptoIconFallback(symbol);
  }

  private cryptoIconFallback(symbol: string): string {
    const label = (symbol || '?').toUpperCase().slice(0, 4);
    const svg = `<svg xmlns="http://www.w3.org/2000/svg" width="64" height="64">
      <rect width="64" height="64" rx="14" fill="#0b1320"/>
      <text x="50%" y="50%" fill="#ffffff" font-size="18" font-family="Arial, sans-serif" font-weight="700" text-anchor="middle" dominant-baseline="middle">${label}</text>
    </svg>`;
    return `data:image/svg+xml;utf8,${encodeURIComponent(svg)}`;
  }

  private parseNumber(value: string | number | undefined | null): number | null {
    if (value === null || value === undefined) {
      return null;
    }
    const normalized = String(value).trim().replace(',', '.');
    if (!normalized) {
      return null;
    }
    const parsed = Number(normalized);
    return Number.isFinite(parsed) ? parsed : null;
  }

  private buildCategoryTotals(transactions: TransactionResponse[], direction: 'IN' | 'OUT'): SpendingCategorySummary[] {
    const totals = new Map<string, SpendingCategorySummary>();
    for (const t of transactions) {
      if (t.direction !== direction) {
        continue;
      }
      const currency = (t.currency || 'EUR').toUpperCase();
      const category = (t.category && t.category.trim().length > 0) ? t.category : 'Overig';
      if (this.isNonCashflowCategory(category)) {
        continue;
      }
      const key = `${currency}::${category}`;
      const amount = Math.abs(t.amount ?? 0);
      const current = totals.get(key);
      if (current) {
        current.total += amount;
      } else {
        totals.set(key, { category, currency, total: amount });
      }
    }
    return Array.from(totals.values()).sort((a, b) => b.total - a.total);
  }

  private isNonCashflowCategory(category?: string | null): boolean {
    if (!category) {
      return false;
    }
    const normalized = category.trim().toLowerCase();
    return normalized === 'transfer' || normalized === 'crypto';
  }

  private refreshCategoryNames() {
    this.categories = this.categoryEntities
      .map((item) => item.name)
      .filter((name) => name && name.trim().length > 0)
      .sort((a, b) => a.localeCompare(b));
    if (this.categories.length === 0) {
      this.categories = [...this.defaultCategories];
    }
    if (!this.categories.includes(this.ruleCategory)) {
      this.ruleCategory = this.categories[0] ?? 'Overig';
    }
    if (this.transactionCategoryFilter !== 'ALL' && !this.categories.includes(this.transactionCategoryFilter)) {
      this.transactionCategoryFilter = 'ALL';
    }
  }

  private filterTransactionsByMonth(transactions: TransactionResponse[], month: string): TransactionResponse[] {
    if (!month || month.length < 7) {
      return transactions;
    }
    const [yearStr, monthStr] = month.split('-');
    const year = Number(yearStr);
    const monthIndex = Number(monthStr) - 1;
    if (!Number.isFinite(year) || !Number.isFinite(monthIndex) || monthIndex < 0 || monthIndex > 11) {
      return transactions;
    }
    return transactions.filter((t) => {
      const dateValue = t.bookingDate ?? t.valueDate;
      if (!dateValue) {
        return false;
      }
      const date = new Date(dateValue);
      if (Number.isNaN(date.getTime())) {
        return false;
      }
      return date.getFullYear() === year && date.getMonth() === monthIndex;
    });
  }

  private resetState() {
    if (this.syncPollTimer) {
      clearInterval(this.syncPollTimer);
      this.syncPollTimer = undefined;
    }
    this.providers = [];
    this.connections = [];
    this.accounts = [];
    this.transactions = [];
    this.cryptoTransactions = [];
    this.rules = [];
    this.goals = [];
    this.recurring = [];
    this.householdBalance = null;
    this.summary = null;
    this.spending = [];
    this.households = [];
    this.selectedProvider = null;
    this.connectionName = '';
    this.connectionConfig = {};
    this.statusMessage = '';
    this.selectedAccountIds = [];
    this.editingAccountId = null;
    this.editingCategoryId = null;
    this.labelDrafts = {};
    this.categoryDrafts = {};
    this.categoryApplyFuture = {};
    this.auditPage = 1;
    this.categoryEntities = [];
    this.categoryNewName = '';
    this.categoryEditingId = null;
    this.categoryEditDrafts = {};
    this.categories = [];
    this.manualAccountName = '';
    this.manualAccountIban = '';
    this.manualAccountOpeningBalance = '';
    this.manualAccountCurrency = 'EUR';
    this.directionFilter = 'ALL';
    this.transactionQuery = '';
    this.transactionCategoryFilter = 'ALL';
    this.transactionsRangeMode = 'MONTH';
    this.ruleMatchType = 'MERCHANT';
    this.ruleMatchMode = 'CONTAINS';
    this.ruleMatchValue = '';
    this.ruleCategory = 'Overig';
    this.ruleApplyHistory = true;
    this.selectedCryptoAssetId = null;
    this.goalName = '';
    this.goalTarget = '';
    this.goalMonthly = '';
    this.goalCurrency = 'EUR';
    this.goalAuto = true;
    this.goalDrafts = {};
    this.goalMonthlyDrafts = {};
    this.goalAutoDrafts = {};
  }

  private defaultRange() {
    const to = new Date();
    const from = new Date();
    from.setDate(to.getDate() - 30);
    return {
      from: from.toISOString().slice(0, 10),
      to: to.toISOString().slice(0, 10)
    };
  }

  private allTimeRange() {
    const to = new Date();
    return {
      from: '2015-01-01',
      to: to.toISOString().slice(0, 10)
    };
  }

  private monthRange(month: string) {
    const [yearStr, monthStr] = (month || '').split('-');
    const year = Number(yearStr);
    const monthIndex = Number(monthStr) - 1;
    if (!Number.isFinite(year) || !Number.isFinite(monthIndex) || monthIndex < 0 || monthIndex > 11) {
      return this.defaultRange();
    }
    const from = new Date(Date.UTC(year, monthIndex, 1));
    const to = new Date(Date.UTC(year, monthIndex + 1, 0));
    return {
      from: from.toISOString().slice(0, 10),
      to: to.toISOString().slice(0, 10)
    };
  }

  private loadTransactions() {
    if (!this.token) {
      return;
    }
    const range = this.transactionsRangeMode === 'ALL'
      ? this.allTimeRange()
      : this.monthRange(this.month);
    this.api.transactions(this.token, range.from, range.to).subscribe({
      next: (transactions) => {
        let result = [...transactions];
        if (this.transactionsRangeMode === 'MONTH') {
          result = this.filterTransactionsByMonth(result, this.month);
        }
        this.transactions = result.sort((a, b) => {
          const aDate = a.bookingDate || a.valueDate || '';
          const bDate = b.bookingDate || b.valueDate || '';
          return bDate.localeCompare(aDate);
        });
      },
      error: () => this.transactions = []
    });
  }

  private loadCryptoTransactions() {
    if (!this.token) {
      return;
    }
    const range = this.allTimeRange();
    this.api.transactions(this.token, range.from, range.to).subscribe({
      next: (transactions) => {
        const cryptoIds = new Set(this.cryptoAccounts.map((a) => a.id));
        this.cryptoTransactions = transactions
          .filter((t) => cryptoIds.has(t.accountId))
          .sort((a, b) => {
            const aDate = a.bookingDate || a.valueDate || '';
            const bDate = b.bookingDate || b.valueDate || '';
            return bDate.localeCompare(aDate);
          });
      },
      error: () => {
        this.cryptoTransactions = [];
      }
    });
  }

  toggleAccountFilter(accountId: string) {
    if (!this.filterableBankAccounts.some((a) => a.id === accountId)) {
      return;
    }
    if (this.selectedAccountIds.includes(accountId)) {
      this.selectedAccountIds = this.selectedAccountIds.filter((id) => id !== accountId);
    } else {
      this.selectedAccountIds = [...this.selectedAccountIds, accountId];
    }
    this.loadTransactions();
  }

  clearAccountFilter() {
    this.selectedAccountIds = [];
    this.transactionsPage = 1;
    this.loadTransactions();
  }

  setSpendingDirection(direction: 'IN' | 'OUT') {
    this.spendingDirection = direction;
    this.spendingSelectedCategory = 'ALL';
    this.spendingTxPage = 1;
  }

  clearCryptoSelection() {
    this.selectedCryptoAssetId = null;
  }

  openCryptoTransactions() {
    if (!this.selectedCryptoAssetId) {
      return;
    }
    this.transactionsRangeMode = 'ALL';
    this.selectedAccountIds = [this.selectedCryptoAssetId];
    this.directionFilter = 'ALL';
    this.transactionCategoryFilter = 'ALL';
    this.transactionQuery = '';
    this.transactionsPage = 1;
    this.filtersCollapsed = false;
    this.setSection('transactions', { preserveTransactionsRange: true });
    this.loadTransactions();
  }

  setDirectionFilter(filter: 'ALL' | 'IN' | 'OUT') {
    this.directionFilter = filter;
  }

  createManualAccount() {
    if (!this.token) {
      return;
    }
    if (!this.manualAccountName.trim()) {
      this.statusMessage = 'Vul een naam in voor de rekening.';
      return;
    }
    if (!this.manualAccountIban.trim()) {
      this.statusMessage = 'Vul een IBAN in voor de rekening.';
      return;
    }
    const openingRaw = this.manualAccountOpeningBalance;
    let openingBalance: number | null = null;
    if (openingRaw !== null && openingRaw !== undefined && String(openingRaw).trim().length > 0) {
      const normalized = String(openingRaw).replace(',', '.');
      const parsed = Number(normalized);
      openingBalance = Number.isFinite(parsed) ? parsed : null;
    }
    const payload = {
      type: 'BANK',
      provider: 'Manual',
      name: this.manualAccountName.trim(),
      label: this.manualAccountName.trim(),
      currency: this.manualAccountCurrency || 'EUR',
      iban: this.manualAccountIban.trim(),
      openingBalance: Number.isFinite(openingBalance) ? openingBalance : null
    };
    this.api.createAccount(this.token, payload).subscribe({
      next: (created) => {
        this.statusMessage = 'Handmatige rekening toegevoegd.';
        if (created) {
          this.accounts = [created, ...this.accounts.filter((a) => a.id !== created.id)];
        }
        this.manualAccountName = '';
        this.manualAccountIban = '';
        this.manualAccountOpeningBalance = '';
        this.loadAll();
      },
      error: (err) => {
        this.statusMessage = err?.error?.message ?? 'Kon rekening niet toevoegen.';
      }
    });
  }

  deleteManualAccount(account: AccountResponse) {
    if (!this.token || !this.isManualAccount(account)) {
      return;
    }
    if (!window.confirm(`Handmatige rekening "${this.accountDisplayName(account)}" verwijderen?`)) {
      return;
    }
    this.api.deleteAccount(this.token, account.id).subscribe({
      next: () => {
        this.statusMessage = 'Handmatige rekening verwijderd.';
        this.accounts = this.accounts.filter((a) => a.id !== account.id);
        this.selectedAccountIds = this.selectedAccountIds.filter((id) => id !== account.id);
        this.loadAll();
      },
      error: (err) => {
        this.statusMessage = err?.error?.message ?? 'Kon rekening niet verwijderen.';
      }
    });
  }

  startEditLabel(account: AccountResponse) {
    this.editingAccountId = account.id;
    this.labelDrafts[account.id] = account.label ?? account.name;
  }

  cancelEditLabel() {
    this.editingAccountId = null;
  }

  saveAccountLabel(account: AccountResponse) {
    if (!this.token) {
      return;
    }
    const label = this.labelDrafts[account.id] ?? '';
    this.api.updateAccount(this.token, account.id, { label }).subscribe({
      next: (updated) => {
        this.accounts = this.accounts.map((a) => a.id === updated.id ? updated : a);
        this.editingAccountId = null;
      },
      error: () => {
        this.statusMessage = 'Kon rekeningnaam niet opslaan.';
      }
    });
  }

  startEditCategory(tx: TransactionResponse) {
    this.editingCategoryId = tx.id;
    this.categoryDrafts[tx.id] = tx.category || 'Overig';
    if (this.categoryApplyFuture[tx.id] === undefined) {
      this.categoryApplyFuture[tx.id] = true;
    }
  }

  cancelEditCategory() {
    this.editingCategoryId = null;
  }

  saveCategory(tx: TransactionResponse) {
    if (!this.token) {
      return;
    }
    const category = (this.categoryDrafts[tx.id] || '').trim();
    if (!category) {
      this.statusMessage = 'Kies een categorie.';
      return;
    }
    const applyToFuture = !!this.categoryApplyFuture[tx.id];
    this.api.updateTransactionCategory(this.token, tx.id, { category, applyToFuture }).subscribe({
      next: (updated) => {
        this.transactions = this.transactions.map((item) => item.id === updated.id ? updated : item);
        this.editingCategoryId = null;
        this.statusMessage = applyToFuture
          ? 'Categorie opgeslagen + toegepast op toekomstige transacties.'
          : 'Categorie opgeslagen.';
      },
      error: (err) => {
        this.statusMessage = err?.error?.message ?? 'Categorie opslaan mislukt.';
      }
    });
  }
}
