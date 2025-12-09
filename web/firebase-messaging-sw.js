importScripts("https://www.gstatic.com/firebasejs/8.10.1/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/8.10.1/firebase-messaging.js");

firebase.initializeApp({
  apiKey: "AIzaSyDFN-73p8zKVZbA0i5DtO215XzAb-xuGSE",
  authDomain: "ammart-8885e.firebaseapp.com",
  databaseURL: "https://ammart-8885e-default-rtdb.firebaseio.com",
  projectId: "ammart-8885e",
  storageBucket: "ammart-8885e.appspot.com",
  messagingSenderId: "1000163153346",
  appId: "1:1000163153346:web:4f702a4b5adbd5c906b25b",
  measurementId: "G-L1GNL2YV61"
});


// firebase.initializeApp({
//     apiKey: "AIzaSyxxxxxxx",
//     authDomain: "bqfresh-68d58.firebaseapp.com",
//     projectId: "bqfresh-68d58",
//     storageBucket: "bqfresh-68d58.appspot.com",
//     messagingSenderId: "1234567890",
//     appId: "1:1234567890:web:abcdef123456",
// });




const messaging = firebase.messaging();

messaging.setBackgroundMessageHandler(function (payload) {
    const promiseChain = clients
        .matchAll({
            type: "window",
            includeUncontrolled: true
        })
        .then(windowClients => {
            for (let i = 0; i < windowClients.length; i++) {
                const windowClient = windowClients[i];
                windowClient.postMessage(payload);
            }
        })
        .then(() => {
            const title = payload.notification.title;
            const options = {
                body: payload.notification.score
              };
            return registration.showNotification(title, options);
        });
    return promiseChain;
});
self.addEventListener('notificationclick', function (event) {
    console.log('notification received: ', event)
});