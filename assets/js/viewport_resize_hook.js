function debounce(func, wait) {
    let timeout;
    return function() {
        const context = this, args = arguments;
        clearTimeout(timeout);
        timeout = setTimeout(() => func.apply(context, args), wait);
    };
}
export function createViewportResizeHooks() {
    return {
        ViewportResizeHooks: {
            mounted () {
                console.log("ViewportResizeHooks mount")
                // Direct push of current window size to properly update view
                this.pushResizeEvent()

                let resizeHandler = debounce(() => {
                    this.pushResizeEvent()
                }, 300)
                window.addEventListener('resize', resizeHandler)
            },

            pushResizeEvent () {
                this.pushEvent('resized', {
                    width: window.innerWidth,
                    height: window.innerHeight
                })
            },

            turbolinksDisconnected () {
                window.removeEventListener('resize', resizeHandler)
            }
        }
    }
}
