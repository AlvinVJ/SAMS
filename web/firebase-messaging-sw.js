importScripts("https://www.gstatic.com/firebasejs/10.7.1/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.7.1/firebase-messaging-compat.js");

const firebaseConfig = {
    apiKey: "AIzaSyAfP45ZV9ROymqk0p4QU5e1SosP8Ndues8",
    appId: "1:791583603828:web:78ebb9ee19c2c5ca5e6521",
    messagingSenderId: "791583603828",
    projectId: "sams-d2236",
    authDomain: "sams-d2236.firebaseapp.com",
    storageBucket: "sams-d2236.firebasestorage.app",
    measurementId: "G-MWJ4YZ7XHC"
};

firebase.initializeApp(firebaseConfig);
const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
    console.log('[firebase-messaging-sw.js] Received background message ', payload);

    const notificationTitle = payload.notification?.title || payload.data?.title || 'Notification';
    const notificationOptions = {
        body: payload.notification?.body || payload.data?.body || '',
        icon: '/icons/Icon-192.png',
    };

    return self.registration.showNotification(notificationTitle, notificationOptions);
});
