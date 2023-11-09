'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';
const RESOURCES = {
  "assets/AssetManifest.json": "9cfbaaad32dcedb98da6cd1396fa87b4",
"assets/assets/88.svg": "0de14a169107eb693bd7fd74fbc8cea1",
"assets/assets/about.svg": "18cd58f2a0f46a3b651704f72703d68f",
"assets/assets/animations/loader_animation.riv": "a7340e2166d7dd545d261a308e42629d",
"assets/assets/arrow-down.svg": "252bc72b4c8a55069f57639923b3e61c",
"assets/assets/arrow-right.svg": "c80b58e512d0ad1cd1e4331e59ccfd3e",
"assets/assets/arrow_right.jpg": "8fcc7e778f5327dcf60d0c091f1638cb",
"assets/assets/background.jpeg": "ca82e6770a9c6723ef4704e60fc58c5a",
"assets/assets/background.png": "298d9640e77d8c111d70c1bd207a88a2",
"assets/assets/background1.jpg": "fff79a5fd0d32bef50dcf707e93f3212",
"assets/assets/background2.jpg": "06a19ee2836d88bbf8841c27c6885665",
"assets/assets/back_ground.png": "a9326374f9fe03055938c15cc3c798ff",
"assets/assets/browser.PNG": "e6e558d1cf36acd039cb0682acb0df94",
"assets/assets/CalFresh.svg": "d8af6faedfcf9649fd2cf960e244a789",
"assets/assets/change-password.svg": "6c0718965c384ade3c2d8a18ca25a6eb",
"assets/assets/Dashboard.svg": "96891638a089a3852af5bcf4e8957caf",
"assets/assets/Department%2520of%2520Public.svg": "d248df5b92df1068061a179e8a6e7db2",
"assets/assets/edit-profle.svg": "57ff470097615a683e564bbbf1fd3202",
"assets/assets/fonts/AtkinsonHyperlegible-Bold.ttf": "7b1ba8889f85c3dab6525fb9423080a0",
"assets/assets/fonts/AtkinsonHyperlegible-BoldItalic.ttf": "76c2a0e11b06231dcf8a4bfd59928aa6",
"assets/assets/fonts/AtkinsonHyperlegible-Italic.ttf": "53f916cf10dd0192172e0231389ea3c0",
"assets/assets/fonts/AtkinsonHyperlegible-Regular.ttf": "fddc5cdae4c83375f5533d16d29613de",
"assets/assets/fonts/OFL.txt": "b046eb27ae21d6003af59338e1120700",
"assets/assets/fonts/Poppins-Bold.ttf": "124cd57d8f41f6db22a724f882dca3f4",
"assets/assets/fonts/Poppins-ExtraLight.ttf": "a0f2eadb0002101ea5da28381ce16cde",
"assets/assets/fonts/Poppins-Medium.ttf": "614a91afc751f09d049231f828801c20",
"assets/assets/fonts/Poppins-Regular.ttf": "cd6b896a19b4babd1a2fa07498e9fc47",
"assets/assets/fonts/Roboto-Bold.ttf": "fb6210739c4993c1a86f812e6502e471",
"assets/assets/fonts/Roboto-Light.ttf": "01744b0f7878c20cdcbd7b3a18040d33",
"assets/assets/fonts/Roboto-Regular.ttf": "afe8eacfc0903cc0612dc696881f0480",
"assets/assets/globe-language.svg": "6adbd802af79e3f1fdc49d34cfdffb89",
"assets/assets/globew.png": "f1ee4c65bd0e994f45ebae0ec0489b46",
"assets/assets/Glyph.svg": "d8af6faedfcf9649fd2cf960e244a789",
"assets/assets/Group.png": "40e284c5b51c0b9aeb49249ca35926e8",
"assets/assets/Group.svg": "7054930cbda1d787fc3bff9adcefae40",
"assets/assets/Housing%2520agency.svg": "760a09c31ea213a4ac57143211c9ef81",
"assets/assets/Housing,%2520Food,.svg": "e83a4a4ac983622b1b750936c17bca2a",
"assets/assets/humberger-menu.svg": "d1979c007a80ed9e4331c69469f9e79b",
"assets/assets/icons/angle_arrow.svg": "0de14a169107eb693bd7fd74fbc8cea1",
"assets/assets/icons/arrow.png": "3e4448d93fe64d5cb6adbf48d50b7e8e",
"assets/assets/icons/ellipse.png": "5b20a8755f0844662b740f023d454484",
"assets/assets/icons/fetus_size.svg": "006383a384b47f199c5d7b8740ee7b42",
"assets/assets/icons/maternal.png": "87588e3b8fdf45e1daf596bef391e747",
"assets/assets/icons/menu.png": "67639dc6206e48cad3dfdd612b5487a0",
"assets/assets/icons/menu_item.svg": "4c9ab7ab051df510474fbd3c3e75abec",
"assets/assets/icons/profile_icon.svg": "33d6bcad6866fe241e62206c2115c007",
"assets/assets/images/avatar_image.png": "224dadf036346435bcf532b625bddb0f",
"assets/assets/images/Countdown4.mp4": "60f9d1121327d868e4fa24b7aa2b3cda",
"assets/assets/images/giphy.gif": "f794177bd331e1040743895cec1dba5d",
"assets/assets/images/giphy1.gif": "2306cf148b59324ab1da796ed82b2a26",
"assets/assets/images/img.png": "bf7eef968111543cecfa8d0047d6da11",
"assets/assets/images/mobex_new_logo_horizontal.png": "8578245d0d6e8f989e682b4e607ac82e",
"assets/assets/langs/en-US.json": "4c590a068c08670b38bdc30b33efec4f",
"assets/assets/Large.svg": "a1cf8d18e680644e424f184bec8f7a08",
"assets/assets/license/fl_charts.txt": "b7636f2e905c25d35e9b4519f89db816",
"assets/assets/logo.png": "1e4fa06603660bb7356a495ff50e5626",
"assets/assets/logo.svg": "9617424db914fc8705cba2c2ca29b332",
"assets/assets/logout.png": "9b10b4b562c96eabcf237748a8ae1a8c",
"assets/assets/logout.svg": "e582b613f90057bac6b5a2d430fe1b28",
"assets/assets/LQBTQIA.svg": "2a4fadc8824fc0bf2c41aa232d978e16",
"assets/assets/Mental%2520Health%2520Resources.svg": "194c8e40894fe4f3717cff9518e65546",
"assets/assets/mobex-logo.png": "4bebd475878ec05d72f8096fb008afb5",
"assets/assets/mobex_new_logo_horizontal.png": "8578245d0d6e8f989e682b4e607ac82e",
"assets/assets/Modivcare.svg": "7054930cbda1d787fc3bff9adcefae40",
"assets/assets/power.png": "66a89c2d7c0ffcb36479c6e7fd7d43e2",
"assets/assets/Public%2520Programs-1.svg": "283265e54d767a9b586c72125398dba3",
"assets/assets/Public%2520Programs-2.svg": "01a22b7d9932e38f0477166d1691a427",
"assets/assets/Public%2520Programs.svg": "7e3bcc8fdb96e784f55deb527ade1a24",
"assets/assets/Redetermination.svg": "17c59e5adb797c9839f1e31db45576ae",
"assets/assets/Search%2520tool%2520for%2520service.svg": "9a223b4046da001b082f9c39462a6f90",
"assets/assets/story_image.png": "833b5e869935c101fdb4717ed70fd8ea",
"assets/assets/Survey%2520to%2520connec.svg": "e1468bfc8bf4fff656c2d8745d730c79",
"assets/assets/vegetable_bowl.png": "65395d44b87561c174914979dbd8af46",
"assets/FontManifest.json": "8d501ac574479214d315c2e820f73c5e",
"assets/fonts/MaterialIcons-Regular.otf": "e7069dfd19b331be16bed984668fe080",
"assets/NOTICES": "6cea7a8a3fe4dd03fb9c28df8e8f9dde",
"assets/packages/amplify_auth_cognito_dart/lib/src/workers/workers.min.js": "fa547a56fe17f6d8a30eb1f619e370a4",
"assets/packages/amplify_auth_cognito_dart/lib/src/workers/workers.min.js.map": "1f93b876ac2d92594faf557693a1765e",
"assets/packages/amplify_secure_storage_dart/lib/src/worker/workers.min.js": "18a956f0d88ee6ad4db46658c7c74631",
"assets/packages/amplify_secure_storage_dart/lib/src/worker/workers.min.js.map": "9204d39e3c19afe4c1a94565baecf0f9",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "6d342eb68f170c97609e9da345464e5e",
"assets/packages/flutter_inappwebview/assets/t_rex_runner/t-rex.css": "5a8d0222407e388155d7d1395a75d5b9",
"assets/packages/flutter_inappwebview/assets/t_rex_runner/t-rex.html": "16911fcc170c8af1c5457940bd0bf055",
"assets/packages/flutter_neumorphic/fonts/NeumorphicIcons.ttf": "32be0c4c86773ba5c9f7791e69964585",
"assets/packages/font_awesome_flutter/lib/fonts/fa-brands-400.ttf": "b00363533ebe0bfdb95f3694d7647f6d",
"assets/packages/font_awesome_flutter/lib/fonts/fa-regular-400.ttf": "0a94bab8e306520dc6ae14c2573972ad",
"assets/packages/font_awesome_flutter/lib/fonts/fa-solid-900.ttf": "9cda082bd7cc5642096b56fa8db15b45",
"assets/packages/simple_barcode_scanner/assets/barcode.html": "193b939b61e05d87a4182f94c0d9f7da",
"assets/packages/simple_barcode_scanner/assets/html5-qrcode.min.js": "246fdcae30adba42ecd5d593d7fbbede",
"assets/packages/wakelock_web/assets/no_sleep.js": "7748a45cd593f33280669b29c2c8919a",
"assets/packages/window_manager/images/ic_chrome_close.png": "75f4b8ab3608a05461a31fc18d6b47c2",
"assets/packages/window_manager/images/ic_chrome_maximize.png": "af7499d7657c8b69d23b85156b60298c",
"assets/packages/window_manager/images/ic_chrome_minimize.png": "4282cd84cb36edf2efb950ad9269ca62",
"assets/packages/window_manager/images/ic_chrome_unmaximize.png": "4a90c1909cb74e8f0d35794e2f61d8bf",
"canvaskit/canvaskit.js": "97937cb4c2c2073c968525a3e08c86a3",
"canvaskit/canvaskit.wasm": "3de12d898ec208a5f31362cc00f09b9e",
"canvaskit/profiling/canvaskit.js": "c21852696bc1cc82e8894d851c01921a",
"canvaskit/profiling/canvaskit.wasm": "371bc4e204443b0d5e774d64a046eb99",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"flutter.js": "a85fcf6324d3c4d3ae3be1ae4931e9c5",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"index.html": "5ef2b08a1ee611396ece413114309485",
"/": "5ef2b08a1ee611396ece413114309485",
"main.dart.js": "5e0d894e052179f640877b4c9b2acb33",
"manifest.json": "2d03ffd5cd488ad77e840cf2d3e00d75",
"version.json": "3a917efc4d9b15dbc4cf1afce3877e6d"
};

// The application shell files that are downloaded before a service worker can
// start.
const CORE = [
  "main.dart.js",
"index.html",
"assets/AssetManifest.json",
"assets/FontManifest.json"];
// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});

// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});

// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});

self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});

// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}

// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
