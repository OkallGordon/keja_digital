// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import topbar from "../vendor/topbar"

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  params: {_csrf_token: csrfToken}
})

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket


window.addEventListener("phx:play-notification-sound", () => {
  document.getElementById("notification-sound").play();
});

window.addEventListener("phx:play-notification", (e) => {
  const type = e.detail.type;
  const audio = document.getElementById(`notification-${type}`);
  if (audio) {
    audio.play();
  }
});

// Add this to your existing app.js
window.addEventListener("phx:show-notification", (e) => {
  const { title, message } = e.detail;
  
  // Create notification element
  const notification = document.createElement('div');
  notification.className = 'fixed top-4 right-4 bg-white shadow-lg rounded-lg p-4 max-w-sm w-full transition-all duration-500 transform translate-x-full';
  notification.innerHTML = `
    <h4 class="font-bold text-lg">${title}</h4>
    <p class="text-gray-600">${message}</p>
  `;
  
  document.body.appendChild(notification);
  
  // Animate in
  setTimeout(() => {
    notification.classList.remove('translate-x-full');
  }, 100);
  
  // Remove after 5 seconds
  setTimeout(() => {
    notification.classList.add('translate-x-full');
    setTimeout(() => {
      notification.remove();
    }, 500);
  }, 5000);
});

window.addEventListener("phx:download-file", (event) => {
  const { data, filename, content_type } = event.detail;

  if (!data || !filename || !content_type) {
    console.error("Missing required download parameters");
    return;
  }

  try {
    const blob = new Blob([data], { type: content_type });
    const url = URL.createObjectURL(blob);
    const link = document.createElement("a");
    
    link.href = url;
    link.download = filename;
    link.style.display = "none";
    
    document.body.appendChild(link);
    link.click();
    
    setTimeout(() => {
      document.body.removeChild(link);
      URL.revokeObjectURL(url);
    }, 100);
    
  } catch (error) {
    console.error("Download failed:", error);
    // Optionally trigger a Phoenix event to notify the server
    window.dispatchEvent(
      new CustomEvent("phx:download-error", { 
        detail: { error: error.message } 
      })
    );
  }
});

// In assets/js/app.js or where you initialize Liveview
if (typeof liveSocket === 'undefined') {
  let liveSocket = new LiveSocket("/live", Socket, {
    params: {_csrf_token: csrfToken},
    hooks: {
      DownloadFile: {
        mounted() {
          this.handleEvent("download-file", ({data, filename, content_type}) => {
            // Convert base64 back to binary
            const binaryData = atob(data);
            
            // Create blob from binary data
            const bytes = new Uint8Array(binaryData.length);
            for (let i = 0; i < binaryData.length; i++) {
              bytes[i] = binaryData.charCodeAt(i);
            }
            const blob = new Blob([bytes], { type: content_type });
            
            // Create download link and trigger click
            const link = document.createElement('a');
            link.href = window.URL.createObjectURL(blob);
            link.download = filename;
            document.body.appendChild(link);
            link.click();
            document.body.removeChild(link);
            window.URL.revokeObjectURL(link.href);
          });
        }
      }
    }
  });
}

const MobileMenu = {
  mounted() {
    this.handleEvent("toggle_mobile_menu", () => {
      const mobileMenu = document.getElementById("mobile-menu");
      const isHidden = mobileMenu.style.display === "none";
      mobileMenu.style.display = isHidden ? "block" : "none";
    });
  }
};

export default MobileMenu;