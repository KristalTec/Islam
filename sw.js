// Service Worker - Prayer Time Background Checker
const CACHE_NAME = 'adhan-v1';

self.addEventListener('install', e => self.skipWaiting());
self.addEventListener('activate', e => e.waitUntil(clients.claim()));

// Listen for messages from the main page
self.addEventListener('message', event => {
    if (event.data && event.data.type === 'SCHEDULE_ADHAN') {
        const { prayers, sound, volume, city } = event.data;
        schedulePrayers(prayers, sound, volume, city);
    }
});

let scheduledTimers = [];

function clearAllTimers() {
    scheduledTimers.forEach(t => clearTimeout(t));
    scheduledTimers = [];
}

function schedulePrayers(prayers, sound, volume, city) {
    clearAllTimers();

    const nameMap = {
        'Fajr': 'Ø¨ÛÛØ§ÙÛ',
        'Dhuhr': 'ÙÛÙÛÚÛ',
        'Asr': 'Ø¹ÛØ³Ø±',
        'Maghrib': 'ÙÛØºØ±ÛØ¨',
        'Isha': 'Ø¹ÛØ´Ø§'
    };

    const now = new Date();

    Object.entries(prayers).forEach(([key, time]) => {
        if (key === 'Sunrise') return;

        const [hours, minutes] = time.split(':').map(Number);
        const prayerDate = new Date();
        prayerDate.setHours(hours, minutes, 0, 0);

        const msUntil = prayerDate - now;

        if (msUntil > 0 && msUntil < 24 * 60 * 60 * 1000) {
            const timer = setTimeout(async () => {
                const prayerName = nameMap[key];

                // Show notification
                if (self.registration.showNotification) {
                    await self.registration.showNotification('ð Ú©Ø§ØªÛÚ©Ø§ÙÛ Ø¨Ø§ÙÚ¯', {
                        body: `Ø¨Ø§ÙÚ¯Û ${prayerName} â Ø§ÙÙÙ Ø£ÙØ¨Ø±`,
                        icon: 'https://cdn-icons-png.flaticon.com/512/2884/2884657.png',
                        badge: 'https://cdn-icons-png.flaticon.com/512/2884/2884657.png',
                        tag: 'adhan-' + key,
                        requireInteraction: true,
                        vibrate: [200, 100, 200, 100, 200],
                        data: { prayerKey: key, prayerName, sound, volume }
                    });
                }

                // Tell all open clients to play audio & show alert
                const allClients = await clients.matchAll({ includeUncontrolled: true, type: 'window' });
                allClients.forEach(client => {
                    client.postMessage({ type: 'PLAY_ADHAN', prayerKey: key, prayerName });
                });

            }, msUntil);

            scheduledTimers.push(timer);
        }
    });
}

// Handle notification click - open/focus app
self.addEventListener('notificationclick', event => {
    event.notification.close();
    event.waitUntil(
        clients.matchAll({ type: 'window', includeUncontrolled: true }).then(clientList => {
            for (const client of clientList) {
                if (client.url.includes('daily.html') && 'focus' in client) {
                    return client.focus();
                }
            }
            if (clients.openWindow) {
                return clients.openWindow('daily.html');
            }
        })
    );
});
