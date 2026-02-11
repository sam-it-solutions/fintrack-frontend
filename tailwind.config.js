/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ['./src/**/*.{html,ts}'],
  theme: {
    extend: {
      colors: {
        navy: {
          950: '#0b1320',
          900: '#0f1f3a',
          800: '#14294e',
          700: '#1c3a6b',
          100: '#e7ecf5',
          50: '#f4f7fb'
        }
      },
      fontFamily: {
        sans: ['"Plus Jakarta Sans"', 'system-ui', 'sans-serif'],
        display: ['"Space Grotesk"', 'system-ui', 'sans-serif']
      },
      boxShadow: {
        soft: '0 18px 40px rgba(10, 20, 40, 0.08)',
        card: '0 20px 60px rgba(10, 20, 40, 0.10)'
      }
    }
  },
  plugins: []
};
