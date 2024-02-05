
function show_backpack_modal() {
    // const modal = new Modal($targetEl, options);
    // modal.show()
}
export function createPlayerScreenHooks() {
    return {
        PlayerScreenHooks: {
            mounted () {
                console.log("PlayerScreenHooks mount")
                document.getElementById("#equipmentBagModal").addEventListener("click", show_backpack_modal());
            }
        }
    }
}
