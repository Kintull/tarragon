// See the Tailwind configuration guide for advanced usage
// https://tailwindcss.com/docs/configuration

const plugin = require("tailwindcss/plugin")
const fs = require("fs")
const path = require("path")

module.exports = {
    content: [
        "./js/**/*.js",
        "../lib/tarragon_web.ex",
        "../lib/tarragon_web/**/*.*ex",
        "../storybook/**/*.story.exs",
        "../node_modules/flowbite/**/*.js"
    ],
    theme: {
        screens: {
            'xs': '420px',
            // => @media (min-width: 640px) { ... }

            'sm': '640px',
            // => @media (min-width: 640px) { ... }

            'md': '768px',
            // => @media (min-width: 768px) { ... }

            'lg': '1024px',
            // => @media (min-width: 1024px) { ... }

            'xl': '1280px',
            // => @media (min-width: 1280px) { ... }

            '2xl': '1536px',
            // => @media (min-width: 1536px) { ... }
        },
        extend: {
            transitionProperty: {
                'min-height': 'min-height',
                'spacing': 'margin, padding',
            },
            animation: {
                //cubic-bezier(0.4, 0, 0.6, 1)
                "pulse-once": "pulse-once 1.5s cubic-bezier(.5,-0.01,.08,1.05)",
                "victory-cup-glow": "victory-cup-glow 1.5s ease-in infinite alternate",
                "versus-cup-glow": "versus-cup-glow 1.5s ease-in infinite alternate",
            },
            keyframes: {
                "pulse-once": {
                    '0%': {opacity: 0},
                    '100%': {opacity: 1},
                },
                "versus-cup-glow": {
                    '0%': {opacity: 0.4},
                    '100%': {opacity: 1},
                }
            },

            colors: {
                "brown-10": "#FBEEE9",
                "brown-20": "#C28670",
                "brown-30": "#A35133",
                "brown-40": "#733B26",
                "blue-10": "#E9F4FB",
                "blue-20": "#7AA9B8",
                "blue-30": "#326F95",
                "blue-40": "#265573",
                "dark-10": "#65819A",
                "dark-20": "#51677B",
                "dark-30": "#3C4E5D",
                "dark-40": "#28343E",
                "dark-50": "#181F25",
                "beige-10": "#FFF4E5",
                "beige-20": "#DDD3C5",
                "beige-30": "#AD9E88",
                "beige-40": "#796E5F",

                "brand": "#FD4F00",
                "oasis": "#FEF0CA",
                "golden-glow": "#FDE295",
                "gun-powder": "#393F5F",
                "pale-orange": "#FF9760",
                "pickled-bean": "#6B4724",
                "hazel-green": "#6A7E6A",
                "light-carmine-pink": "#E96D5E",
                "metallic-copper": "#752E29",
                "moonlight-silver": "#C0C0C0",
                "crimson-red": "#8B0000",
                "crimson-red-dark": "#530101",
                "sand-dark": "#8C7150",
                "sand": "#D2B076",
                "light-blue": "#8dc3ef",
            },
            fontFamily: {
                'cwisdom': ['Conventional-Wisdom', 'sans-serif'],
                'jotione-regular': ['JotiOne-Regular', 'sans-serif'],
                'metropolis-regular': ['Metropolis-Regular', 'sans-serif'],
                'futura': ['Futura', 'sans-serif']
            },
            gridTemplateColumns: {
                '30': 'repeat(30, minmax(0, 1fr))'
            }
        },
    },
    plugins: [
        require("@tailwindcss/forms"),
        // require("flowbite/plugin"),
        // Allows prefixing tailwind classes with LiveView classes to add rules
        // only when LiveView classes are applied, for example:
        //
        //     <div class="phx-click-loading:animate-ping">
        //
        plugin(({addVariant}) => addVariant("phx-no-feedback", [".phx-no-feedback&", ".phx-no-feedback &"])),
        plugin(({addVariant}) => addVariant("phx-click-loading", [".phx-click-loading&", ".phx-click-loading &"])),
        plugin(({addVariant}) => addVariant("phx-submit-loading", [".phx-submit-loading&", ".phx-submit-loading &"])),
        plugin(({addVariant}) => addVariant("phx-change-loading", [".phx-change-loading&", ".phx-change-loading &"])),

        // Embeds Heroicons (https://heroicons.com) into your app.css bundle
        // See your `CoreComponents.icon/1` for more information.
        //
        plugin(function ({matchComponents, theme}) {
            let iconsDir = path.join(__dirname, "./vendor/heroicons/optimized")
            let values = {}
            let icons = [
                ["", "/24/outline"],
                ["-bold", "/24/outline-bold"],
                ["-solid", "/24/solid"],
                ["-mini", "/20/solid"]
            ]
            icons.forEach(([suffix, dir]) => {
                fs.readdirSync(path.join(iconsDir, dir)).forEach(file => {
                    let name = path.basename(file, ".svg") + suffix
                    values[name] = {name, fullPath: path.join(iconsDir, dir, file)}
                })
            })
            matchComponents({
                "hero": ({name, fullPath}) => {
                    let content = fs.readFileSync(fullPath).toString().replace(/\r?\n|\r/g, "")
                    return {
                        [`--hero-${name}`]: `url('data:image/svg+xml;utf8,${content}')`,
                        "-webkit-mask": `var(--hero-${name})`,
                        "mask": `var(--hero-${name})`,
                        "mask-repeat": "no-repeat",
                        "background-color": "currentColor",
                        "vertical-align": "middle",
                        "display": "inline-block",
                        "width": theme("spacing.5"),
                        "height": theme("spacing.5")
                    }
                }
            }, {values})
        })
    ]
}
