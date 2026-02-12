import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { environment } from '../environments/environment';
import { Observable } from 'rxjs';

export interface AuthResponse {
  token: string;
  userId: string;
}

export interface PasskeyStartResponse {
  challengeId: string;
  options: any;
}

export interface ProviderField {
  key: string;
  label: string;
  required: boolean;
  secret: boolean;
  placeholder: string;
}

export interface ProviderResponse {
  id: string;
  name: string;
  type: string;
  requiresAuth: boolean;
  fields: ProviderField[];
}

export interface EnableBankingAspspResponse {
  name: string;
  country: string;
  bic?: string;
  logo?: string;
  psuTypes?: string[];
}

export interface ConnectionResponse {
  id: string;
  providerId: string;
  displayName: string;
  type: string;
  status: string;
  autoSyncEnabled: boolean;
  lastSyncedAt?: string;
  syncStatus?: string;
  syncStage?: string;
  syncProgress?: number;
  lastSyncStartedAt?: string;
  lastSyncCompletedAt?: string;
  lastSyncError?: string;
  errorMessage?: string;
  createdAt: string;
}

export interface AccountResponse {
  id: string;
  connectionId?: string;
  type: string;
  provider: string;
  name: string;
  label?: string;
  currency: string;
  iban?: string;
  accountNumber?: string;
  currentBalance?: number;
  openingBalance?: number;
  currentFiatValue?: number;
  fiatCurrency?: string;
  lastSyncedAt?: string;
  priceChange24hPct?: number;
}

export interface SummaryResponse {
  summaries: {
    currency: string;
    totalBalance: number;
    totalIncomeMonth: number;
    totalExpenseMonth: number;
  }[];
}

export interface HouseholdResponse {
  id: string;
  name: string;
  inviteCode: string;
  role: string;
}

export interface SpendingCategorySummary {
  category: string;
  currency: string;
  total: number;
}

export interface RecategorizeResponse {
  updatedCount: number;
  totalCount: number;
}

export interface RuleResponse {
  id: string;
  matchType: string;
  matchValue: string;
  matchMode?: string;
  category: string;
  createdAt: string;
  updatedAt: string;
}

export interface CategoryResponse {
  id: string;
  name: string;
  createdAt: string;
  updatedAt: string;
}

export interface SavingsGoalResponse {
  id: string;
  name: string;
  currency: string;
  targetAmount: number;
  currentAmount: number;
  monthlyContribution?: number;
  autoEnabled: boolean;
  lastAppliedMonth?: string;
  createdAt: string;
  updatedAt: string;
}

export interface RecurringPaymentResponse {
  name: string;
  averageAmount: number;
  currency: string;
  occurrences: number;
  months: number;
  lastDate?: string;
}

export interface HouseholdBalanceMember {
  userId: string;
  email: string;
  paid: number;
  share: number;
  balance: number;
}

export interface HouseholdBalanceResponse {
  householdId: string;
  month: string;
  totalExpenses: number;
  perMemberShare: number;
  members: HouseholdBalanceMember[];
}

export interface TransactionResponse {
  id: string;
  accountId: string;
  amount: number;
  currency: string;
  direction: string;
  description?: string;
  bookingDate?: string;
  valueDate?: string;
  category?: string;
  categorySource?: string;
  categoryConfidence?: number;
  categoryReason?: string;
  status?: string;
  transactionType?: string;
  merchantName?: string;
  counterpartyIban?: string;
}

export interface AdminSettingsResponse {
  syncEnabled: boolean;
  syncIntervalMs: number;
  aiEnabled: boolean;
  aiModel?: string;
  updatedAt?: string;
}

export interface AdminSettingsRequest {
  syncEnabled?: boolean;
  syncIntervalMs?: number;
  aiEnabled?: boolean;
  aiModel?: string | null;
}

@Injectable({
  providedIn: 'root'
})
export class ApiService {
  private baseUrl = environment.apiBaseUrl;

  constructor(private http: HttpClient) {}

  register(email: string, password: string): Observable<AuthResponse> {
    return this.http.post<AuthResponse>(`${this.baseUrl}/api/auth/register`, { email, password });
  }

  login(email: string, password: string): Observable<AuthResponse> {
    return this.http.post<AuthResponse>(`${this.baseUrl}/api/auth/login`, { email, password });
  }

  passkeyRegisterStart(token: string): Observable<PasskeyStartResponse> {
    return this.http.post<PasskeyStartResponse>(`${this.baseUrl}/api/auth/passkeys/register/start`, {}, this.authHeaders(token));
  }

  passkeyRegisterFinish(token: string, challengeId: string, credential: any): Observable<void> {
    return this.http.post<void>(
      `${this.baseUrl}/api/auth/passkeys/register/finish`,
      { challengeId, credential },
      this.authHeaders(token)
    );
  }

  getAdminSettings(token: string): Observable<AdminSettingsResponse> {
    return this.http.get<AdminSettingsResponse>(`${this.baseUrl}/api/admin/settings`, this.authHeaders(token));
  }

  updateAdminSettings(token: string, payload: AdminSettingsRequest): Observable<AdminSettingsResponse> {
    return this.http.put<AdminSettingsResponse>(`${this.baseUrl}/api/admin/settings`, payload, this.authHeaders(token));
  }

  passkeyLoginStart(email?: string): Observable<PasskeyStartResponse> {
    const trimmed = email?.trim();
    const payload = trimmed ? { email: trimmed } : {};
    return this.http.post<PasskeyStartResponse>(`${this.baseUrl}/api/auth/passkeys/login/start`, payload);
  }

  passkeyLoginFinish(challengeId: string, credential: any): Observable<AuthResponse> {
    return this.http.post<AuthResponse>(`${this.baseUrl}/api/auth/passkeys/login/finish`, { challengeId, credential });
  }

  listProviders(token: string): Observable<ProviderResponse[]> {
    return this.http.get<ProviderResponse[]>(`${this.baseUrl}/api/providers`, this.authHeaders(token));
  }

  listEnableBankingAspsps(token: string, country = 'BE', psuType = 'personal'): Observable<EnableBankingAspspResponse[]> {
    return this.http.get<EnableBankingAspspResponse[]>(
      `${this.baseUrl}/api/providers/enablebanking/aspsps?country=${country}&psuType=${psuType}`,
      this.authHeaders(token)
    );
  }

  listConnections(token: string): Observable<ConnectionResponse[]> {
    return this.http.get<ConnectionResponse[]>(`${this.baseUrl}/api/connections`, this.authHeaders(token));
  }

  createConnection(token: string, payload: any): Observable<ConnectionResponse> {
    return this.http.post<ConnectionResponse>(`${this.baseUrl}/api/connections`, payload, this.authHeaders(token));
  }

  updateConnection(token: string, connectionId: string, payload: any): Observable<ConnectionResponse> {
    return this.http.patch<ConnectionResponse>(`${this.baseUrl}/api/connections/${connectionId}`, payload, this.authHeaders(token));
  }

  initiateConnection(token: string, connectionId: string): Observable<{ url: string }> {
    return this.http.post<{ url: string }>(`${this.baseUrl}/api/connections/${connectionId}/initiate`, {}, this.authHeaders(token));
  }

  syncConnection(token: string, connectionId: string): Observable<ConnectionResponse> {
    return this.http.post<ConnectionResponse>(`${this.baseUrl}/api/connections/${connectionId}/sync`, {}, this.authHeaders(token));
  }

  deleteConnection(token: string, connectionId: string): Observable<void> {
    return this.http.delete<void>(`${this.baseUrl}/api/connections/${connectionId}`, this.authHeaders(token));
  }

  summary(token: string): Observable<SummaryResponse> {
    return this.http.get<SummaryResponse>(`${this.baseUrl}/api/finance/summary`, this.authHeaders(token));
  }

  spending(token: string, month: string): Observable<SpendingCategorySummary[]> {
    return this.http.get<SpendingCategorySummary[]>(`${this.baseUrl}/api/finance/spending?month=${month}`, this.authHeaders(token));
  }

  accounts(token: string): Observable<AccountResponse[]> {
    return this.http.get<AccountResponse[]>(`${this.baseUrl}/api/finance/accounts`, this.authHeaders(token));
  }

  createAccount(token: string, payload: any): Observable<AccountResponse> {
    return this.http.post<AccountResponse>(`${this.baseUrl}/api/finance/accounts`, payload, this.authHeaders(token));
  }

  shareAccount(token: string, accountId: string, householdId: string): Observable<AccountResponse> {
    return this.http.patch<AccountResponse>(`${this.baseUrl}/api/finance/accounts/${accountId}/share`, { householdId }, this.authHeaders(token));
  }

  updateAccount(token: string, accountId: string, payload: { label?: string }): Observable<AccountResponse> {
    return this.http.patch<AccountResponse>(`${this.baseUrl}/api/finance/accounts/${accountId}`, payload, this.authHeaders(token));
  }

  deleteAccount(token: string, accountId: string): Observable<void> {
    return this.http.delete<void>(`${this.baseUrl}/api/finance/accounts/${accountId}`, this.authHeaders(token));
  }

  transactions(token: string, from: string, to: string): Observable<TransactionResponse[]> {
    return this.http.get<TransactionResponse[]>(`${this.baseUrl}/api/finance/transactions?from=${from}&to=${to}`, this.authHeaders(token));
  }

  recategorizeAll(token: string): Observable<RecategorizeResponse> {
    return this.http.post<RecategorizeResponse>(`${this.baseUrl}/api/finance/transactions/recategorize`, {}, this.authHeaders(token));
  }

  listRules(token: string): Observable<RuleResponse[]> {
    return this.http.get<RuleResponse[]>(`${this.baseUrl}/api/finance/rules`, this.authHeaders(token));
  }

  listCategories(token: string): Observable<CategoryResponse[]> {
    return this.http.get<CategoryResponse[]>(`${this.baseUrl}/api/finance/categories`, this.authHeaders(token));
  }

  createCategory(token: string, payload: { name: string }): Observable<CategoryResponse> {
    return this.http.post<CategoryResponse>(`${this.baseUrl}/api/finance/categories`, payload, this.authHeaders(token));
  }

  updateCategory(token: string, categoryId: string, payload: { name: string }): Observable<CategoryResponse> {
    return this.http.patch<CategoryResponse>(`${this.baseUrl}/api/finance/categories/${categoryId}`, payload, this.authHeaders(token));
  }

  deleteCategory(token: string, categoryId: string): Observable<void> {
    return this.http.delete<void>(`${this.baseUrl}/api/finance/categories/${categoryId}`, this.authHeaders(token));
  }

  createRule(token: string, payload: any): Observable<RuleResponse> {
    return this.http.post<RuleResponse>(`${this.baseUrl}/api/finance/rules`, payload, this.authHeaders(token));
  }

  updateRule(token: string, ruleId: string, payload: any): Observable<RuleResponse> {
    return this.http.patch<RuleResponse>(`${this.baseUrl}/api/finance/rules/${ruleId}`, payload, this.authHeaders(token));
  }

  deleteRule(token: string, ruleId: string): Observable<void> {
    return this.http.delete<void>(`${this.baseUrl}/api/finance/rules/${ruleId}`, this.authHeaders(token));
  }

  applyRuleToHistory(token: string, ruleId: string): Observable<RecategorizeResponse> {
    return this.http.post<RecategorizeResponse>(`${this.baseUrl}/api/finance/rules/${ruleId}/apply`, {}, this.authHeaders(token));
  }

  listGoals(token: string): Observable<SavingsGoalResponse[]> {
    return this.http.get<SavingsGoalResponse[]>(`${this.baseUrl}/api/finance/goals`, this.authHeaders(token));
  }

  createGoal(token: string, payload: any): Observable<SavingsGoalResponse> {
    return this.http.post<SavingsGoalResponse>(`${this.baseUrl}/api/finance/goals`, payload, this.authHeaders(token));
  }

  updateGoal(token: string, goalId: string, payload: any): Observable<SavingsGoalResponse> {
    return this.http.patch<SavingsGoalResponse>(`${this.baseUrl}/api/finance/goals/${goalId}`, payload, this.authHeaders(token));
  }

  deleteGoal(token: string, goalId: string): Observable<void> {
    return this.http.delete<void>(`${this.baseUrl}/api/finance/goals/${goalId}`, this.authHeaders(token));
  }

  recurringPayments(token: string, months = 6): Observable<RecurringPaymentResponse[]> {
    return this.http.get<RecurringPaymentResponse[]>(`${this.baseUrl}/api/finance/recurring?months=${months}`, this.authHeaders(token));
  }

  updateTransactionCategory(token: string, transactionId: string, payload: { category: string; applyToFuture: boolean }): Observable<TransactionResponse> {
    return this.http.patch<TransactionResponse>(`${this.baseUrl}/api/finance/transactions/${transactionId}/category`, payload, this.authHeaders(token));
  }

  householdBalance(token: string, householdId: string, month: string, includeShared = false): Observable<HouseholdBalanceResponse> {
    return this.http.get<HouseholdBalanceResponse>(
      `${this.baseUrl}/api/households/${householdId}/balance?month=${month}&includeShared=${includeShared}`,
      this.authHeaders(token)
    );
  }

  listHouseholds(token: string): Observable<HouseholdResponse[]> {
    return this.http.get<HouseholdResponse[]>(`${this.baseUrl}/api/households`, this.authHeaders(token));
  }

  createHousehold(token: string, name: string): Observable<HouseholdResponse> {
    return this.http.post<HouseholdResponse>(`${this.baseUrl}/api/households`, { name }, this.authHeaders(token));
  }

  joinHousehold(token: string, inviteCode: string): Observable<HouseholdResponse> {
    return this.http.post<HouseholdResponse>(`${this.baseUrl}/api/households/join`, { inviteCode }, this.authHeaders(token));
  }

  deleteHousehold(token: string, householdId: string): Observable<void> {
    return this.http.delete<void>(`${this.baseUrl}/api/households/${householdId}`, this.authHeaders(token));
  }

  private authHeaders(token: string) {
    return {
      headers: new HttpHeaders({
        Authorization: `Bearer ${token}`
      })
    };
  }
}
