var _ = require('./lodash.min')

var DEF_ERR = '操作失败了'

/**
 * request
 * @param url
 * @param params
 * @param option
 * @returns {Promise}
 * @private
 */
function _request(url, params, option) {
  return new Promise((resolve, reject) => {
    fetch(url, _.assign({
      credentials: 'include',
      headers: {
        'X-Requested-With': 'XMLHttpRequest'
      },
      body: JSON.stringify(params),
    }, option)).then((response) => {
      if (response.ok) {
        return response.text()
      } else {
        reject(DEF_ERR)
      }
    }).then((response) => {
      if (response) {
        resolve(JSON.parse(response))
      } else {
        // body 为空
        resolve()
      }
    }).catch((err) => {
      reject(err)
    })
  })
}

/**
 * get 请求
 * @param url
 * @param params
 * @param option
 * @returns {Promise}
 */
function get(url, params, option) {
  return _request(url, params, _.assign(option, {
    method: 'GET',
    headers: {
      'Content-Type': 'application/json'
    }
  }))
}

/**
 * 使用 json 发送 post 请求 ( Content-Type : application/json )
 * @param url
 * @param params
 * @param option
 * @returns {Promise}
 */
function post(url, params, option) {
  return _request(url, params, _.assign(option, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json'
    }
  }))
}

/**
 * 发送 post 请求 ( Content-Type : application/x-www-form-urlencoded )
 * @param url
 * @param params
 * @param option
 * @returns {Promise}
 */
function postForm(url, params, option) {
  return _request(url, params, _.assign(option, {
    method: 'POST',
    body: params,
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded'
    }
  }))
}

module.exports = {
    get,
    post,
    postForm,
}
