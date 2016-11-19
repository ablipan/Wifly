// fuse module
var Observable = require('FuseJS/Observable')
var Environment = require('FuseJS/Environment')
var Lifecycle = require('FuseJS/Lifecycle')
var Base64 = require("FuseJS/Base64")

// js module
var model = require('./utils/model')
var Notification = require('./components/Notification')(globalNotification)
// Uno module
var Clipboard = require('Clipboard')
var WifiConnector = require('WifiConnector')

var AI_GUIST_URL = 'http://hram-elb2-1033590448.cn-north-1.elb.amazonaws.com.cn/wemedia_2.0/common/commonAction!aiguest'
var loading = Observable(false)
var error = Observable('')
var password = Observable('')
var qrcodeUrl = Observable('')
var qrcodeVisible = Observable(false)
var logs = Observable()
var logViewVisible = Observable(false)

function addLog(text, type) {
    logs.add({
        text,
        color: type ? '#e07470' : '#2ef700'
    })
    setTimeout(function() {
        LogScrollView.gotoRelative(0, 1)
    }, 500)
}

function clearLog() {
    logs.clear()
}

Lifecycle.onEnteringBackground = function() {
    clearLog()
}

function _parseAiGuestPass(password) {
    password = password.match(/>.*</ig)[0]
    password = password.match(/>.*</ig)[0]
    return password.substr(1, password.length - 2 )
}

function fly() {
    if (loading.value) {
        return
    }
    loading.value = true
    password.value = null
    addLog('正在获取 AI-Guest 密码...')
    model.get(AI_GUIST_URL).then(function(result) {
        if(result.status === 0) {
            try{
                var _password = _parseAiGuestPass(result.data.redata)
                password.value = _password
                qrcodeUrl.value = 'http://qr.topscan.com/api.php?fg=2db7f5&pt=00a0e9&inpt=1e80d3&gc=1e80d3&m=20&text=' + Base64.encodeUtf8(_password)
                // copy to clipboard
                Clipboard.copy(_password).then(function() {
                    addLog('密码 ' +_password+ ' 已复制到剪切板')
                    if(Environment.ios) {
                        addLog('iOS 系统请到 Wi-Fi 设置中手动连接。')
                    }
                }, function(err) {
                    Notification.error(err)
                })
                if(Environment.android) {
                    var auth = WifiConnector.authorize()
                    // Why?
                    // http://stackoverflow.com/questions/32151603/scan-results-available-action-return-empty-list-in-android-6-0
                    // reference:
                    // 1. https://www.fusetools.com/community/forums/howto_discussions/android_permissions_1?size=50
                    // 2. https://github.com/bolav/fuse-contacts/blob/master/ContactsImpl.Android.uno#L135-L155
                    if (Environment.mobileOSVersion.startsWith('6')) {
                        addLog('请求位置信息访问权限 ...')
                        auth.then(function() {
                            _connect()
                        }, function() {
                            addLog('缺少位置信息权限，无法自动连接 Wi-Fi', 1)
                        })
                    } else {
                        _connect()
                    }
                }
            } catch(e) {
                password.value = ''
                Notification.error('获取 AI-Guest 密码失败!')
            }
        } else {
            Notification.error(result.errmsg || '获取 AI-Guest 密码失败!')
        }
    }, function(err) {
        password.value = ''
        Notification.error(err || '获取 AI-Guest 密码失败!')
    }).then(function() {
        setTimeout(function() {
            loading.value = false
        }, 500)
    })
}

// iOS 自动获取密码
if(Environment.ios) {
    fly()
}

function _connect() {
    WifiConnector.connect('AI_GUEST', password.value).then(function(result) {
        if (result === 1001){
            addLog('当前 Wi-Fi 已连接 AI-Guest', 1)
        } else if(result == 0) {
            addLog('Wi-Fi 连接请求完成')
        } else if(result == 4) {
            addLog('未搜索到 AI-Guest', 1)
        } else {
            addLog('Bang ~ 发生了什么...', 2)
        }
    }, function(err) {
        Notification.error(err)
    })
}

function exit() {
    // TODO 退出应用
}

function share() {
    qrcodeVisible.value = true
}

function hideQrcode() {
    qrcodeVisible.value = false
}

module.exports = {
    fly,
    loading,
    password,
    qrcodeUrl,
    exit,
    logs,
    clearLog,
    share,
    logViewVisible,
    hideQrcode,
    qrcodeVisible,
}