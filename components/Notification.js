/**
* How to use?
* See Notification.ux
*/
module.exports = function(event) {
    return {
        info: function(text) {
            event.raise({
                text,
                type: 'info'
            })
        },
        success: function(text) {
            event.raise({
                text,
                type: 'success'
            })
        },
        warning: function(text) {
            event.raise({
                text,
                type: 'warning'
            })
        },
        error: function(text) {
            event.raise({
                text,
                type: 'error'
            })
        }
    }
}