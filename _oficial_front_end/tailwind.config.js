/** @type {import('tailwindcss').Config} */
export default {
    content: ['./index.html', './src/**/*.{js,ts,jsx,tsx}'],
    theme: {
        screens: {
            sm: "800px",
            sd: '1110px',
            md: "1280px",
            lg: "1920px",
            xl: "2180px"
        },
        extend: {
            colors: {
                text: {
                    secondary: "#B9BBBE"
                },
                "blue-custom": "rgb(var(--panel-primary, 114 137 218) / <alpha-value>)",
                "red-custom": "#ED4245",
            },
            animation: {
                // "injured-pulse": 'injured 1s ease-in-out infinite',
                // 'pulse-scale': 'pulse-scale 2s ease-in-out infinite',
            },
            keyframes: {
                // "injured": {
                //     '0%, 100%': { outline: '2px solid #dc2626' },
                //     '50%': { outline: '2px solid #dc262614' },
                // },
                // 'pulse-scale': {
                //     '0%, 100%': { transform: 'scale(1)' },
                //     '50%': { transform: 'scale(1.05)' },
                // },
            },
            zoom: {
                0: '0',
                50: '.5',
                70: '.75',
                75: '.75',
                90: '.9',
                95: '.95',
                100: '1',
                110: '1.1',
                125: '1.25',
                150: '1.5',
                200: '2',
            },
            fontFamily: {
                notoSans: ['Noto Sans'],
            },
        },
    },
    plugins: [
        function ({ addUtilities }) {
            const newUtilities = {
                '.zoom-0': { zoom: '0' },
                '.zoom-50': { zoom: '.5' },
                '.zoom-70': { zoom: '.70' },
                '.zoom-75': { zoom: '.75' },
                '.zoom-90': { zoom: '.9' },
                '.zoom-95': { zoom: '.95' },
                '.zoom-100': { zoom: '1' },
                '.zoom-110': { zoom: '1.1' },
                '.zoom-125': { zoom: '1.25' },
                '.zoom-150': { zoom: '1.5' },
                '.zoom-200': { zoom: '2' },
            };
            addUtilities(newUtilities, ['responsive']);
        },
    ],
}
