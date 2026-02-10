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
<<<<<<< HEAD

// Define LiveView hooks
let Hooks = {
  QRCode: {
    mounted() {
      this.generateQRCode()
    },
    updated() {
      // Only regenerate if QR data has changed
      const currentData = this.el.getAttribute("data-qr-data")
      if (currentData !== this.lastData) {
        this.lastData = currentData
        this.generateQRCode()
      }
    },
    generateQRCode() {
      const element = this.el
      const qrData = element.getAttribute("data-qr-data")
      
      if (!qrData) return
      
      // Store current data to detect changes
      this.lastData = qrData
      
      // Clear existing QR code
      element.innerHTML = ""
      
      // Wait for QRCode library to be available
      const tryGenerate = () => {
        if (typeof QRCode !== "undefined") {
          try {
            // Determine QR code size based on container
            const containerId = element.id
            const isSmallCard = containerId && (containerId.includes('profile') || containerId.includes('qrcode-profile'))
            const qrSize = isSmallCard ? 120 : 200
            
            new QRCode(element, {
              text: qrData,
              width: qrSize,
              height: qrSize,
              colorDark: "#000000",
              colorLight: "#ffffff",
              correctLevel: QRCode.CorrectLevel.H
            })
          } catch (error) {
            console.error("Error generating QR code:", error)
          }
        } else {
          // If library not loaded yet, wait a bit and try again
          setTimeout(tryGenerate, 100)
        }
      }
      
      tryGenerate()
    }
  },
  QRScanner: {
    mounted() {
      this.html5QrCode = null
      this.isScanning = false
      this.lastScannedCode = null
      this.lastScanTime = 0
      this.setupScanner()
      // Auto-start scanner when mounted
      setTimeout(() => {
        if (!this.isScanning) {
          this.startScanner()
        }
      }, 500)
    },
    updated() {
      // Auto-start scanner if not already scanning when tab becomes visible
      if (!this.isScanning && this.el.offsetParent !== null) {
        setTimeout(() => {
          if (!this.isScanning) {
            this.startScanner()
          }
        }, 300)
      }
    },
    destroyed() {
      this.stopScanner()
    },
    showScanSuccess() {
      // Create or get success message element
      let successDiv = document.getElementById("scan-success")
      if (!successDiv) {
        successDiv = document.createElement("div")
        successDiv.id = "scan-success"
        successDiv.className = "fixed top-20 left-1/2 transform -translate-x-1/2 z-50 bg-green-500 text-white px-6 py-3 rounded-lg shadow-lg text-center font-semibold"
        successDiv.style.display = "none"
        successDiv.textContent = "QR Detected. Thank you!"
        document.body.appendChild(successDiv)
      }
      
      // Show success message
      successDiv.style.display = "block"
      successDiv.style.animation = "fadeInOut 2s ease-in-out"
      
      // Hide after 2 seconds
      setTimeout(() => {
        successDiv.style.display = "none"
      }, 2000)
    },
    setupScanner() {
      // Wait for Html5Qrcode to be available
      if (typeof Html5Qrcode === "undefined") {
        setTimeout(() => this.setupScanner(), 100)
        return
      }
      
      // Look for buttons within this hook's container
      const container = this.el
      const startBtn = container.querySelector("#start-scanner-btn")
      const stopBtn = container.querySelector("#stop-scanner-btn")
      
      if (startBtn) {
        startBtn.addEventListener("click", () => this.startScanner())
      }
      if (stopBtn) {
        stopBtn.addEventListener("click", () => this.stopScanner())
      }
    },
    startScanner() {
      // Wait for Html5Qrcode to be available
      if (typeof Html5Qrcode === "undefined") {
        const container = this.el
        const errorDiv = container.querySelector("#qr-scanner-error")
        const statusText = container.querySelector("#qr-status-text")
        
        if (errorDiv) {
          errorDiv.textContent = "Loading QR scanner library..."
          errorDiv.classList.remove("hidden")
        }
        if (statusText) {
          statusText.textContent = "Loading QR scanner library..."
        }
        
        setTimeout(() => this.startScanner(), 100)
        return
      }
      
      // Look for elements within this hook's container
      const container = this.el
      const qrReader = container.querySelector("#qr-reader") || document.getElementById("qr-reader")
      const startBtn = container.querySelector("#start-scanner-btn") || document.getElementById("start-scanner-btn")
      const stopBtn = container.querySelector("#stop-scanner-btn") || document.getElementById("stop-scanner-btn")
      const errorDiv = container.querySelector("#qr-scanner-error")
      const statusText = container.querySelector("#qr-status-text")
      
      if (!qrReader) {
        console.error("QR reader element not found")
        if (errorDiv) {
          errorDiv.textContent = "QR reader element not found"
          errorDiv.classList.remove("hidden")
        }
        return
      }
      
      // Stop any existing scanner
      if (this.html5QrCode) {
        this.html5QrCode.stop().catch(() => {})
        this.html5QrCode = null
      }
      
      // Clear error messages
      if (errorDiv) {
        errorDiv.classList.add("hidden")
        errorDiv.textContent = ""
      }
      
      // Update status
      if (statusText) {
        statusText.textContent = "Starting camera..."
      }
      
      // Clear and show reader
      qrReader.innerHTML = ""
      qrReader.classList.remove("hidden")
      
      // Reset scan tracking
      this.lastScannedCode = null
      this.lastScanTime = 0
      
      // Use the element's ID for Html5Qrcode
      const qrReaderId = qrReader.id || "qr-reader"
      this.html5QrCode = new Html5Qrcode(qrReaderId)
      
      const qrboxSize = this.calculateQRBoxSize()
      const cameraConfigs = [
        { facingMode: "environment" },
        { facingMode: "user" },
        { deviceId: { exact: undefined } }
      ]
      
      let configIndex = 0
      
      const tryStartCamera = (config) => {
        this.html5QrCode.start(
          config,
          {
            fps: 10,
            qrbox: qrboxSize,
            aspectRatio: 1.0,
            videoConstraints: {
              facingMode: config.facingMode || "environment",
              width: { ideal: 1280 },
              height: { ideal: 720 }
            }
          },
          (decodedText, decodedResult) => {
            const currentTime = Date.now()
            // Prevent duplicate scans within 3 seconds (increased from 2)
            if (decodedText === this.lastScannedCode && (currentTime - this.lastScanTime) < 3000) {
              return
            }
            
            this.lastScannedCode = decodedText
            this.lastScanTime = currentTime
            
            // Send to LiveView using hook's pushEvent
            console.log("QR Code scanned:", decodedText)
            this.pushEvent("scan_qr", { qr_data: decodedText })
            
            // Visual feedback - show success message
            this.showScanSuccess()
            
            // Vibrate device if supported (mobile)
            if (navigator.vibrate) {
              navigator.vibrate(200)
            }
            
            // Scanner continues running - do NOT stop it
          },
          () => {} // Ignore scanning errors
        ).then(() => {
          this.isScanning = true
          if (startBtn) startBtn.classList.add("hidden")
          if (stopBtn) stopBtn.classList.remove("hidden")
          if (statusText) {
            statusText.textContent = "Camera active - Point at QR code"
          }
          if (errorDiv) {
            errorDiv.classList.add("hidden")
          }
        }).catch((err) => {
          console.error("Error starting scanner:", err)
          configIndex++
          if (configIndex < cameraConfigs.length) {
            if (statusText) {
              statusText.textContent = `Trying camera ${configIndex + 1} of ${cameraConfigs.length}...`
            }
            tryStartCamera(cameraConfigs[configIndex])
          } else {
            this.isScanning = false
            if (startBtn) startBtn.classList.remove("hidden")
            if (stopBtn) stopBtn.classList.add("hidden")
            if (qrReader) {
              qrReader.classList.add("hidden")
            }
            const errorMsg = err.message || "Failed to start camera. Please check permissions and try again."
            if (errorDiv) {
              errorDiv.textContent = errorMsg
              errorDiv.classList.remove("hidden")
            }
            if (statusText) {
              statusText.textContent = "Camera failed to start. Click Start Scanner to try again."
            }
          }
        })
      }
      
      tryStartCamera(cameraConfigs[0])
    },
    stopScanner() {
      if (this.html5QrCode && this.isScanning) {
        this.html5QrCode.stop().then(() => {
          this.isScanning = false
          this.html5QrCode = null
          
          // Look for elements within this hook's container
          const container = this.el
          const startBtn = container.querySelector("#start-scanner-btn") || document.getElementById("start-scanner-btn")
          const stopBtn = container.querySelector("#stop-scanner-btn") || document.getElementById("stop-scanner-btn")
          const qrReader = container.querySelector("#qr-reader") || document.getElementById("qr-reader")
          
          if (startBtn) startBtn.classList.remove("hidden")
          if (stopBtn) stopBtn.classList.add("hidden")
          if (qrReader) {
            qrReader.innerHTML = ""
            qrReader.classList.add("hidden")
          }
        }).catch(() => {})
      }
    },
    calculateQRBoxSize() {
      const isMobile = window.innerWidth <= 768
      if (isMobile) {
        const minSize = Math.min(window.innerWidth - 40, 300)
        return { width: minSize, height: minSize }
      }
      return { width: 250, height: 250 }
    }
  },
  FaceScanner: {
    mounted() {
      this.video = null
      this.canvas = null
      this.isScanning = false
      this.modelsLoaded = false
      this.faceDescriptors = new Map() // Map of user_id -> face descriptor
      this.lastRecognizedUserId = null
      this.lastRecognitionTime = 0
      this.processingUserId = null  // Track which user is being processed
      this.recognitionInterval = null
      this.stream = null
      this.eventListenersAttached = false
      this.faceApiLoadAttempts = 0
      this.maxFaceApiLoadAttempts = 20 // 10 seconds max wait
      this.overlayCanvasResized = false
      
      // Get students data from LiveView
      this.students = this.el.getAttribute("data-students") 
        ? JSON.parse(this.el.getAttribute("data-students"))
        : []
      
      // Wait a bit for DOM to be ready, then setup
      setTimeout(() => {
        this.setupScanner()
      }, 100)
      
      // Ensure face-api.js is loaded before loading models
      this.ensureFaceApiLoaded().then(() => {
      this.loadModels()
      }).catch((error) => {
        console.error("Failed to load face-api.js:", error)
        this.updateStatus("Error: Could not load face recognition library. Please refresh the page.")
      })
    },
    updated() {
      // Update students list if it changed
      const newStudents = this.el.getAttribute("data-students")
        ? JSON.parse(this.el.getAttribute("data-students"))
        : []
      
      if (JSON.stringify(newStudents) !== JSON.stringify(this.students)) {
        this.students = newStudents
        if (this.modelsLoaded) {
          this.loadFaceDescriptors()
        }
      }
      
      // Re-setup scanner if elements are now available
      if (!this.eventListenersAttached) {
        setTimeout(() => {
          this.setupScanner()
        }, 100)
      }
    },
    destroyed() {
      this.stopScanner()
      // Remove event listeners
      if (this.containerClickHandler) {
        this.el.removeEventListener("click", this.containerClickHandler)
      }
      if (this.resizeHandler) {
        window.removeEventListener("resize", this.resizeHandler)
      }
    },
    async ensureFaceApiLoaded() {
      return new Promise((resolve, reject) => {
        // Check if already loaded (try both global and window)
        const faceApiAvailable = typeof faceapi !== "undefined" || typeof window.faceapi !== "undefined"
        if (faceApiAvailable) {
          console.log("face-api.js already loaded")
          // Ensure it's on window if not already
          if (typeof faceapi !== "undefined" && typeof window.faceapi === "undefined") {
            window.faceapi = faceapi
          }
          resolve()
          return
        }
        
        // Check if script tag exists
        const existingScript = document.querySelector('script[src*="face-api"]')
        if (existingScript) {
          // Script tag exists, wait for it to load
          const checkLoaded = () => {
            if (typeof faceapi !== "undefined" || typeof window.faceapi !== "undefined") {
              if (typeof window.faceapi !== "undefined" && typeof faceapi === "undefined") {
                window.faceapi = window.faceapi
              }
              console.log("face-api.js loaded from existing script tag")
              resolve()
            } else {
              this.faceApiLoadAttempts++
              if (this.faceApiLoadAttempts >= this.maxFaceApiLoadAttempts) {
                reject(new Error("Script loaded but faceapi is still undefined after waiting"))
              } else {
                setTimeout(checkLoaded, 500)
              }
            }
          }
          
          existingScript.onload = () => {
            setTimeout(checkLoaded, 100)
          }
          existingScript.onerror = () => {
            console.log("Existing script failed, trying to load locally...")
            this.loadFaceApiLocally().then(resolve).catch(reject)
          }
          
          // If script already loaded (onload already fired)
          if (existingScript.complete || existingScript.readyState === "complete") {
            setTimeout(checkLoaded, 100)
          } else {
            // Wait for script to load
            setTimeout(checkLoaded, 1000)
          }
        } else {
          // No script tag, try to load from CDN first, then local
          this.loadFaceApiFromCDN().then(resolve).catch(() => {
            this.loadFaceApiLocally().then(resolve).catch(reject)
          })
        }
      })
    },
    
    async loadFaceApiFromCDN() {
      return new Promise((resolve, reject) => {
        // Check if already exists
        if (document.querySelector('script[src*="unpkg.com/face-api"]')) {
          console.log("CDN script already exists, waiting for it to load...")
          const checkInterval = setInterval(() => {
            if (typeof faceapi !== "undefined" || typeof window.faceapi !== "undefined") {
              clearInterval(checkInterval)
              resolve()
            }
            this.faceApiLoadAttempts++
            if (this.faceApiLoadAttempts >= this.maxFaceApiLoadAttempts) {
              clearInterval(checkInterval)
              reject(new Error("CDN script exists but faceapi never loaded"))
            }
          }, 500)
          return
        }
        
        const script = document.createElement("script")
        script.src = "https://unpkg.com/face-api.js@0.22.2/dist/face-api.min.js"
        script.async = true
        script.onload = () => {
          // Wait a bit for faceapi to be available
          const checkLoaded = () => {
            if (typeof faceapi !== "undefined" || typeof window.faceapi !== "undefined") {
              console.log("face-api.js loaded from CDN")
              resolve()
            } else {
              this.faceApiLoadAttempts++
              if (this.faceApiLoadAttempts >= this.maxFaceApiLoadAttempts) {
                reject(new Error("CDN script loaded but faceapi is undefined"))
              } else {
                setTimeout(checkLoaded, 200)
              }
            }
          }
          setTimeout(checkLoaded, 100)
        }
        script.onerror = () => {
          reject(new Error("Failed to load face-api.js from CDN"))
        }
        document.head.appendChild(script)
      })
    },
    
    async loadFaceApiLocally() {
      return new Promise((resolve, reject) => {
        // Check if already exists
        if (document.querySelector('script[src*="/models/dist/face-api"]')) {
          console.log("Local script already exists, waiting for it to load...")
          const checkInterval = setInterval(() => {
            if (typeof faceapi !== "undefined" || typeof window.faceapi !== "undefined") {
              clearInterval(checkInterval)
              resolve()
            }
            this.faceApiLoadAttempts++
            if (this.faceApiLoadAttempts >= this.maxFaceApiLoadAttempts) {
              clearInterval(checkInterval)
              reject(new Error("Local script exists but faceapi never loaded"))
            }
          }, 500)
          return
        }
        
        const script = document.createElement("script")
        script.src = "/models/dist/face-api.min.js"
        script.async = true
        script.onload = () => {
          // Wait a bit for faceapi to be available
          const checkLoaded = () => {
            if (typeof faceapi !== "undefined" || typeof window.faceapi !== "undefined") {
              console.log("face-api.js loaded from local file")
              resolve()
            } else {
              this.faceApiLoadAttempts++
              if (this.faceApiLoadAttempts >= this.maxFaceApiLoadAttempts) {
                reject(new Error("Local script loaded but faceapi is undefined"))
              } else {
                setTimeout(checkLoaded, 200)
              }
            }
          }
          setTimeout(checkLoaded, 100)
        }
        script.onerror = () => {
          reject(new Error("Failed to load face-api.js from local file"))
        }
        document.head.appendChild(script)
      })
    },
    
    async loadModels() {
      // Double-check face-api.js is available (try both global and window)
      let faceApi = typeof faceapi !== "undefined" ? faceapi : (typeof window.faceapi !== "undefined" ? window.faceapi : null)
      if (!faceApi) {
        console.error("face-api.js is not available")
        this.updateStatus("Error: Face recognition library not loaded. Please refresh the page.")
        return
      }
      
      // Ensure faceapi is available globally for the rest of the code
      if (typeof faceapi === "undefined") {
        window.faceapi = faceApi
        // Also try to set it as a global if possible
        try {
          if (typeof global !== "undefined") {
            global.faceapi = faceApi
          }
        } catch (e) {
          // Ignore if can't set global
        }
      }
      
      // Store reference for this instance
      this.faceapi = faceApi
      
      try {
        // Try unpkg CDN first (more reliable for face-api.js models)
        const MODEL_URL = "https://unpkg.com/face-api.js@0.22.2/weights"
        
        console.log("Loading face-api models from:", MODEL_URL)
        this.updateStatus("Loading face recognition models...")
        
        await Promise.all([
          faceApi.nets.tinyFaceDetector.loadFromUri(MODEL_URL),
          faceApi.nets.faceLandmark68Net.loadFromUri(MODEL_URL),
          faceApi.nets.faceRecognitionNet.loadFromUri(MODEL_URL)
        ])
        
        this.modelsLoaded = true
        console.log("Face API models loaded successfully")
        this.updateStatus("Models loaded. Loading student faces...")
        await this.loadFaceDescriptors()
        this.updateStatus("Ready to scan. Click Start Scanner to begin.")
      } catch (error) {
        console.error("Error loading face-api models from unpkg:", error)
        // Try jsdelivr with trailing slash
        try {
          console.log("Trying jsdelivr CDN...")
          const ALT_MODEL_URL = "https://cdn.jsdelivr.net/npm/face-api.js@0.22.2/weights/"
          this.updateStatus("Trying alternative model source...")
          
          await Promise.all([
            faceApi.nets.tinyFaceDetector.loadFromUri(ALT_MODEL_URL),
            faceApi.nets.faceLandmark68Net.loadFromUri(ALT_MODEL_URL),
            faceApi.nets.faceRecognitionNet.loadFromUri(ALT_MODEL_URL)
          ])
          
          this.modelsLoaded = true
          console.log("Face API models loaded successfully from jsdelivr")
          this.updateStatus("Models loaded. Loading student faces...")
          await this.loadFaceDescriptors()
          this.updateStatus("Ready to scan. Click Start Scanner to begin.")
        } catch (altError) {
          console.error("Error loading from jsdelivr:", altError)
          // Last resort: try loading from local /models directory
          try {
            console.log("Trying local models directory...")
            const LOCAL_MODEL_URL = "/models/weights"
            this.updateStatus("Trying local models...")
            
            await Promise.all([
              faceApi.nets.tinyFaceDetector.loadFromUri(LOCAL_MODEL_URL),
              faceApi.nets.faceLandmark68Net.loadFromUri(LOCAL_MODEL_URL),
              faceApi.nets.faceRecognitionNet.loadFromUri(LOCAL_MODEL_URL)
            ])
            
            this.modelsLoaded = true
            console.log("Face API models loaded successfully from local directory")
            this.updateStatus("Models loaded. Loading student faces...")
            await this.loadFaceDescriptors()
            this.updateStatus("Ready to scan. Click Start Scanner to begin.")
          } catch (localError) {
            console.error("Error loading from local directory:", localError)
            this.updateStatus(`Error loading face recognition models. Please download models to /models directory or check your internet connection.`)
          }
        }
      }
    },
    async loadFaceDescriptors() {
      this.faceDescriptors.clear()
      this.updateStatus(`Loading ${this.students.length} student face(s)...`)
      
      for (const student of this.students) {
        if (!student.avatar_url) continue
        
        try {
          // Load image from avatar URL
          const img = await this.loadImage(student.avatar_url)
          
          // Get faceapi reference
          const faceApi = this.faceapi || (typeof faceapi !== "undefined" ? faceapi : (typeof window.faceapi !== "undefined" ? window.faceapi : null))
          if (!faceApi) {
            console.error("face-api.js not available in loadFaceDescriptors")
            return
          }
          
          // Detect face and get descriptor
          const detection = await faceApi
            .detectSingleFace(img, new faceApi.TinyFaceDetectorOptions())
            .withFaceLandmarks()
            .withFaceDescriptor()
          
          if (detection) {
            this.faceDescriptors.set(student.id, detection.descriptor)
            console.log(`Loaded face descriptor for ${student.name} (ID: ${student.id})`)
          } else {
            console.warn(`No face detected in profile picture for ${student.name}`)
          }
        } catch (error) {
          console.error(`Error loading face for ${student.name}:`, error)
        }
      }
      
      this.updateStatus(`Loaded ${this.faceDescriptors.size} student face(s). Ready to scan.`)
    },
    loadImage(url) {
      return new Promise((resolve, reject) => {
        const img = new Image()
        img.crossOrigin = "anonymous"
        img.onload = () => resolve(img)
        img.onerror = reject
        // Handle relative URLs
        if (url.startsWith("/")) {
          img.src = window.location.origin + url
        } else {
          img.src = url
        }
      })
    },
    setupScanner() {
      // Use event delegation on the container to handle button clicks
      // This works even if buttons are recreated
      if (!this.eventListenersAttached) {
        this.containerClickHandler = (e) => {
          if (e.target && e.target.id === "start-scanner-btn") {
            e.preventDefault()
            e.stopPropagation()
            console.log("Start scanner button clicked (delegated)")
            this.startScanner()
          } else if (e.target && e.target.id === "stop-scanner-btn") {
            e.preventDefault()
            e.stopPropagation()
            console.log("Stop scanner button clicked (delegated)")
            this.stopScanner()
          }
        }
        
        this.el.addEventListener("click", this.containerClickHandler)
        console.log("Event delegation set up on container")
        this.eventListenersAttached = true
      }
      
      // Also try direct attachment as backup
      const startBtn = document.getElementById("start-scanner-btn")
      const stopBtn = document.getElementById("stop-scanner-btn")
      
      if (startBtn && !startBtn.dataset.listenerAttached) {
        startBtn.addEventListener("click", (e) => {
          e.preventDefault()
          e.stopPropagation()
          console.log("Start scanner button clicked (direct)")
          this.startScanner()
        })
        startBtn.dataset.listenerAttached = "true"
        console.log("Direct event listener attached to start button")
      }
      
      if (stopBtn && !stopBtn.dataset.listenerAttached) {
        stopBtn.addEventListener("click", (e) => {
          e.preventDefault()
          e.stopPropagation()
          console.log("Stop scanner button clicked (direct)")
          this.stopScanner()
        })
        stopBtn.dataset.listenerAttached = "true"
        console.log("Direct event listener attached to stop button")
      }
      
      this.video = document.getElementById("video")
      this.canvas = document.getElementById("canvas")
      this.overlayCanvas = document.getElementById("overlay-canvas")
      this.guideFrame = document.getElementById("face-guide-frame")
      this.instructions = document.getElementById("face-instructions")
      
      if (this.video) {
        console.log("Video element found")
      } else {
        console.warn("Video element not found")
      }
      
      // Setup overlay canvas when video is ready
      if (this.video && this.overlayCanvas) {
        this.video.addEventListener("loadedmetadata", () => {
          this.resizeOverlayCanvas()
        })
        
        // Handle window resize
        this.resizeHandler = () => {
          if (this.isScanning) {
            this.resizeOverlayCanvas()
          }
        }
        window.addEventListener("resize", this.resizeHandler)
      }
    },
    resizeOverlayCanvas() {
      if (this.video && this.overlayCanvas) {
        const videoRect = this.video.getBoundingClientRect()
        const currentWidth = this.overlayCanvas.width
        const currentHeight = this.overlayCanvas.height
        
        // Only resize if dimensions changed
        if (currentWidth !== videoRect.width || currentHeight !== videoRect.height) {
          this.overlayCanvas.width = videoRect.width
          this.overlayCanvas.height = videoRect.height
          this.overlayCanvas.style.width = videoRect.width + "px"
          this.overlayCanvas.style.height = videoRect.height + "px"
        }
      }
    },
    async startScanner() {
      console.log("startScanner called", {
        modelsLoaded: this.modelsLoaded,
        faceDescriptorsSize: this.faceDescriptors.size,
        isScanning: this.isScanning
      })
      
      if (!this.modelsLoaded) {
        this.updateStatus("Face recognition models are still loading. Please wait...")
        return
      }
      
      if (this.faceDescriptors.size === 0) {
        this.updateStatus("No student faces loaded. Students need to upload profile pictures.")
        return
      }
      
      if (this.isScanning) {
        console.log("Scanner is already running")
        return
      }
      
      const faceReader = document.getElementById("face-reader")
      const startBtn = document.getElementById("start-scanner-btn")
      const stopBtn = document.getElementById("stop-scanner-btn")
      
      if (!faceReader) {
        console.error("face-reader element not found")
        this.updateStatus("Error: Scanner container not found")
        return
      }
      
      if (!this.video) {
        this.video = document.getElementById("video")
        if (!this.video) {
          console.error("video element not found")
          this.updateStatus("Error: Video element not found")
          return
        }
      }
      
      try {
        console.log("Requesting camera access...")
        // Get user media
        this.stream = await navigator.mediaDevices.getUserMedia({
          video: { 
            facingMode: "user",
            width: { ideal: 640 },
            height: { ideal: 480 }
          }
        })
        
        console.log("Camera access granted")
        this.video.srcObject = this.stream
        faceReader.classList.remove("hidden")
        
        if (startBtn) startBtn.classList.add("hidden")
        if (stopBtn) stopBtn.classList.remove("hidden")
        
        this.isScanning = true
        this.updateStatus("Scanning for faces...")
        
        // Initialize guide frame
        this.updateGuideFrame(false, false)
        this.overlayCanvasResized = false
        
        // Wait for video to be ready
        this.video.onloadedmetadata = () => {
          console.log("Video metadata loaded, starting recognition loop")
          this.resizeOverlayCanvas()
          this.overlayCanvasResized = true
          // Start recognition loop
          this.startRecognitionLoop()
        }
        
        // Fallback: start loop after a short delay
        setTimeout(() => {
          if (this.isScanning && !this.recognitionInterval) {
            console.log("Starting recognition loop (fallback)")
            this.resizeOverlayCanvas()
            this.overlayCanvasResized = true
            this.startRecognitionLoop()
          }
        }, 500)  // Reduced from 1000ms
      } catch (error) {
        console.error("Error accessing camera:", error)
        this.updateStatus(`Error accessing camera: ${error.message}. Please check permissions.`)
        this.isScanning = false
        
        // Show error in UI
        const errorDiv = document.getElementById("scanner-error")
        if (errorDiv) {
          errorDiv.textContent = `Camera error: ${error.message}`
          errorDiv.classList.remove("hidden")
        }
      }
    },
    startRecognitionLoop() {
      if (!this.isScanning) {
        console.log("Not starting recognition loop - scanner not active")
        return
      }
      
      // Get faceapi reference (try stored, then global, then window)
      const faceApi = this.faceapi || (typeof faceapi !== "undefined" ? faceapi : (typeof window.faceapi !== "undefined" ? window.faceapi : null))
      if (!faceApi) {
        console.error("face-api.js not available")
        this.updateStatus("Face recognition library not loaded")
        return
      }
      
      console.log("Starting face recognition loop")
      
      // Optimized face detector options for speed
      // Smaller inputSize = faster but less precise for small faces
      // Higher scoreThreshold = faster, fewer false positives
      const detectorOptions = new faceApi.TinyFaceDetectorOptions({
        inputSize: 224,  // Reduced from default 416 for speed (224, 320, 416, 512, 608)
        scoreThreshold: 0.6  // Slightly higher to reduce false positives
      })
      
      let isProcessing = false
      let frameSkip = 0
      const FRAME_SKIP_COUNT = 1  // Process every 2nd frame for even more speed
      let animationFrameId = null
      
      const processFrame = async () => {
        // Check if scanning was stopped
        if (!this.isScanning) {
          return
        }
        if (!this.isScanning || !this.video || this.video.readyState !== 4) {
          if (this.video && this.video.readyState !== 4) {
            console.log("Video not ready, state:", this.video.readyState)
          }
          requestAnimationFrame(processFrame)
          return
        }
        
        // Check if scanning was stopped
        if (!this.isScanning) {
          return
        }
        
        // Skip frames if still processing
        if (isProcessing) {
          animationFrameId = requestAnimationFrame(processFrame)
          return
        }
        
        // Skip every Nth frame for performance
        frameSkip++
        if (frameSkip <= FRAME_SKIP_COUNT) {
          animationFrameId = requestAnimationFrame(processFrame)
          return
        }
        frameSkip = 0
        
        isProcessing = true
        
        try {
          // Resize overlay canvas to match video (only when needed)
          if (!this.overlayCanvasResized) {
            this.resizeOverlayCanvas()
            this.overlayCanvasResized = true
          }
          
          // Detect faces and compute descriptors in one go for immediate recognition
          const detections = await faceApi
            .detectAllFaces(this.video, detectorOptions)
            .withFaceLandmarks()
            .withFaceDescriptors()
          
          // Draw face detection boxes on overlay
          this.drawFaceDetections(detections)
          
          if (detections.length === 0) {
            this.updateGuideFrame(false, false)
            this.updateStatus("Position face in frame")
            isProcessing = false
            if (this.isScanning) {
              animationFrameId = requestAnimationFrame(processFrame)
            }
            return
          }
          
          // Early exit optimization - check if we have descriptors
          if (this.faceDescriptors.size === 0) {
            this.updateGuideFrame(true, false)
            this.updateStatus("No student faces loaded")
            isProcessing = false
            if (this.isScanning) {
              animationFrameId = requestAnimationFrame(processFrame)
            }
            return
          }
          
          // Find best match - optimized loop
          let bestMatch = null
          let bestDistance = Infinity
          const MATCH_THRESHOLD = 0.6
          
          // Use the first (largest/most confident) detection
          const detection = detections[0]
          
          // Optimized matching - break early if we find a very good match
            for (const [userId, referenceDescriptor] of this.faceDescriptors.entries()) {
            const distance = faceApi.euclideanDistance(
                detection.descriptor,
                referenceDescriptor
              )
              
              // Lower distance = better match
            if (distance < MATCH_THRESHOLD && distance < bestDistance) {
                bestDistance = distance
                bestMatch = userId
              
              // Early exit if we find a very good match (< 0.4)
              if (distance < 0.4) {
                break
              }
            }
          }
          
          if (bestMatch) {
            const currentTime = Date.now()
            // Prevent duplicate recognitions within 2 seconds to avoid connection issues
            if (bestMatch === this.lastRecognizedUserId && 
                (currentTime - this.lastRecognitionTime) < 2000) {
              // Keep showing green for recognized face
              this.updateGuideFrame(true, true)
              isProcessing = false
              if (this.isScanning) {
                animationFrameId = requestAnimationFrame(processFrame)
              }
              return
            }
            
            // Check if we're already processing this user
            if (this.processingUserId === bestMatch) {
              console.log("Already processing this user, skipping...")
              isProcessing = false
              if (this.isScanning) {
                animationFrameId = requestAnimationFrame(processFrame)
              }
              return
            }
            
            this.lastRecognizedUserId = bestMatch
            this.lastRecognitionTime = currentTime
            this.processingUserId = bestMatch  // Mark as processing
            
            // Immediately update guide frame to green and record
            console.log("=== FACE RECOGNIZED ===")
            console.log("User ID:", bestMatch)
            console.log("Distance:", bestDistance.toFixed(3))
            console.log("Updating guide frame to green and sending event...")
            this.updateGuideFrame(true, true)
            this.updateStatus("Recording attendance...")
            
            // Allow processing to continue
            isProcessing = false
            
            // Use regular pushEvent - more reliable with connection issues
            // The backend will handle recording and update the stream
            console.log("=== SENDING RECOGNIZE_FACE EVENT ===")
            console.log("User ID:", bestMatch)
            console.log("User ID type:", typeof bestMatch)
            console.log("User ID string:", String(bestMatch))
            
            try {
              // Use regular pushEvent which is more stable
              const eventData = { user_id: String(bestMatch) }
              console.log("Event data:", eventData)
              console.log("pushEvent available?", typeof this.pushEvent === "function")
              
              this.pushEvent("recognize_face", eventData)
              console.log("Event sent successfully via pushEvent")
              
              // Show success immediately (backend handles recording)
            this.showRecognitionSuccess()
              this.updateStatus("✓ Attendance recorded!")
            
            // Vibrate if supported
            if (navigator.vibrate) {
                navigator.vibrate(100)
              }
              
              // Reset guide frame after a moment
              setTimeout(() => {
                this.updateGuideFrame(false, false)
                // Reset last recognition to allow immediate next scan
                this.lastRecognizedUserId = null
                this.lastRecognitionTime = 0
                this.processingUserId = null
                this.updateStatus("Ready for next student...")
              }, 800)
              
            } catch (error) {
              console.error("Error sending recognize_face event:", error)
              this.updateStatus("Error: Failed to send attendance request")
              this.updateGuideFrame(true, false)
              this.processingUserId = null
            }
            
            // Continue processing next frame
            if (this.isScanning) {
              animationFrameId = requestAnimationFrame(processFrame)
            }
            return
          } else {
            // Face detected but not recognized - show yellow
            this.updateGuideFrame(true, false)
            this.updateStatus("Face not recognized")
            isProcessing = false
            if (this.isScanning) {
              animationFrameId = requestAnimationFrame(processFrame)
            }
          }
        } catch (error) {
          console.error("Error during face recognition:", error)
          isProcessing = false
          if (this.isScanning) {
            animationFrameId = requestAnimationFrame(processFrame)
          }
        }
      }
      
      // Store animation frame ID for cancellation
      this.recognitionAnimationFrame = () => {
        animationFrameId = requestAnimationFrame(processFrame)
      }
      
      // Start the loop using requestAnimationFrame for better performance
      animationFrameId = requestAnimationFrame(processFrame)
    },
    stopScanner() {
      this.isScanning = false
      
      // Clear any pending animation frames
      if (this.recognitionInterval) {
        clearInterval(this.recognitionInterval)
        this.recognitionInterval = null
      }
      
      // Cancel animation frame if it exists
      if (this.recognitionAnimationFrame) {
        // The loop will stop because isScanning is false
        this.recognitionAnimationFrame = null
      }
      
      this.overlayCanvasResized = false
      
      if (this.stream) {
        this.stream.getTracks().forEach(track => track.stop())
        this.stream = null
      }
      
      if (this.video) {
        this.video.srcObject = null
      }
      
      // Clear overlay canvas
      if (this.overlayCanvas) {
        const ctx = this.overlayCanvas.getContext("2d")
        ctx.clearRect(0, 0, this.overlayCanvas.width, this.overlayCanvas.height)
      }
      
      const startBtn = document.getElementById("start-scanner-btn")
      const stopBtn = document.getElementById("stop-scanner-btn")
      const faceReader = document.getElementById("face-reader")
      
      if (startBtn) startBtn.classList.remove("hidden")
      if (stopBtn) stopBtn.classList.add("hidden")
      if (faceReader) faceReader.classList.add("hidden")
      
      this.updateStatus("Scanner stopped.")
      this.lastRecognizedUserId = null
      this.lastRecognitionTime = 0
      
      // Reset guide frame
      if (this.guideFrame) {
        this.guideFrame.style.borderColor = "rgba(34, 197, 94, 0.6)"
        this.guideFrame.style.boxShadow = "0 0 20px rgba(34, 197, 94, 0.3)"
      }
      if (this.instructions) {
        this.instructions.textContent = "Position your face within the frame"
        this.instructions.style.background = "rgba(0, 0, 0, 0.7)"
      }
    },
    updateStatus(message) {
      const statusText = document.getElementById("status-text")
      if (statusText) {
        statusText.textContent = message
      }
    },
    drawFaceDetections(detections) {
      if (!this.overlayCanvas || !this.video || !detections || detections.length === 0) {
        // Clear canvas if no detections
        if (this.overlayCanvas) {
          const ctx = this.overlayCanvas.getContext("2d")
          ctx.clearRect(0, 0, this.overlayCanvas.width, this.overlayCanvas.height)
        }
        return
      }
      
      const ctx = this.overlayCanvas.getContext("2d")
      const videoWidth = this.video.videoWidth || 640
      const videoHeight = this.video.videoHeight || 480
      
      // Clear canvas
      ctx.clearRect(0, 0, this.overlayCanvas.width, this.overlayCanvas.height)
      
      // Scale factor - use canvas dimensions directly for better performance
      const scaleX = this.overlayCanvas.width / videoWidth
      const scaleY = this.overlayCanvas.height / videoHeight
      
      // Only draw the first (most confident) detection for speed
      const detection = detections[0]
      const box = detection.detection ? detection.detection.box : detection.box
      const x = box.x * scaleX
      const y = box.y * scaleY
      const width = box.width * scaleX
      const height = box.height * scaleY
      
      // Draw bounding box - simplified for speed
      ctx.strokeStyle = "#22c55e" // Green
      ctx.lineWidth = 3
      ctx.strokeRect(x, y, width, height)
      
      // Skip landmarks drawing for performance - it's not essential
    },
    updateGuideFrame(faceDetected, faceRecognized) {
      if (!this.guideFrame || !this.instructions) return
      
      // Get corner indicators
      const corners = this.guideFrame.querySelectorAll("div")
      
      if (faceRecognized) {
        // Face recognized - bright green, immediately recording
        this.guideFrame.style.borderColor = "rgba(34, 197, 94, 1)"
        this.guideFrame.style.boxShadow = "0 0 30px rgba(34, 197, 94, 0.6)"
        corners.forEach(corner => {
          corner.style.borderColor = "#22c55e"
        })
        this.instructions.textContent = "✓ Recording attendance..."
        this.instructions.style.background = "rgba(34, 197, 94, 0.9)"
      } else if (faceDetected) {
        // Face detected but not recognized - yellow/orange
        this.guideFrame.style.borderColor = "rgba(251, 191, 36, 0.8)"
        this.guideFrame.style.boxShadow = "0 0 20px rgba(251, 191, 36, 0.4)"
        corners.forEach(corner => {
          corner.style.borderColor = "#fbbf24"
        })
        this.instructions.textContent = "Face not recognized"
        this.instructions.style.background = "rgba(251, 191, 36, 0.8)"
      } else {
        // No face detected - red/orange
        this.guideFrame.style.borderColor = "rgba(239, 68, 68, 0.6)"
        this.guideFrame.style.boxShadow = "0 0 20px rgba(239, 68, 68, 0.3)"
        corners.forEach(corner => {
          corner.style.borderColor = "#ef4444"
        })
        this.instructions.textContent = "Position your face within the frame"
        this.instructions.style.background = "rgba(239, 68, 68, 0.7)"
      }
    },
    showRecognitionSuccess() {
      let successDiv = document.getElementById("scan-success")
      if (!successDiv) {
        successDiv = document.createElement("div")
        successDiv.id = "scan-success"
        successDiv.className = "fixed top-20 left-1/2 transform -translate-x-1/2 z-50 bg-green-500 text-white px-6 py-3 rounded-lg shadow-lg text-center font-semibold"
        successDiv.style.display = "none"
        document.body.appendChild(successDiv)
      }
      
      successDiv.textContent = "Face Recognized! Attendance recorded."
      successDiv.style.display = "block"
      successDiv.style.animation = "fadeInOut 2s ease-in-out"
      
      setTimeout(() => {
      successDiv.style.display = "none"
    }, 2000)
    },
    showRecognitionError(errorMsg) {
      let errorDiv = document.getElementById("scan-error-message")
      if (!errorDiv) {
        errorDiv = document.createElement("div")
        errorDiv.id = "scan-error-message"
        errorDiv.className = "fixed top-20 left-1/2 transform -translate-x-1/2 z-50 bg-red-500 text-white px-6 py-3 rounded-lg shadow-lg text-center font-semibold"
        errorDiv.style.display = "none"
        document.body.appendChild(errorDiv)
      }
      
      errorDiv.textContent = `Error: ${errorMsg}`
      errorDiv.style.display = "block"
      errorDiv.style.animation = "fadeInOut 3s ease-in-out"
      
      setTimeout(() => {
        errorDiv.style.display = "none"
      }, 3000)
  }
  },
  CameraCapture: {
    mounted() {
      this.video = document.getElementById("camera-video")
      this.canvas = document.getElementById("camera-canvas")
      this.captureBtn = document.getElementById("capture-btn")
      this.saveBtn = document.getElementById("save-capture-btn")
      this.retakeBtn = document.getElementById("retake-btn")
      this.previewDiv = document.getElementById("capture-preview")
      this.previewImage = document.getElementById("preview-image")
      this.stream = null
      this.capturedDataUrl = null
      
      this.setupCamera()
      this.setupEventListeners()
    },
    destroyed() {
      this.stopCamera()
    },
    async setupCamera() {
      try {
        this.stream = await navigator.mediaDevices.getUserMedia({
          video: {
            facingMode: "user",
            width: { ideal: 640 },
            height: { ideal: 480 }
          }
        })
        
        if (this.video) {
          this.video.srcObject = this.stream
        }
      } catch (error) {
        console.error("Error accessing camera:", error)
        alert("Unable to access camera. Please check permissions.")
      }
    },
    setupEventListeners() {
      if (this.captureBtn) {
        this.captureBtn.addEventListener("click", () => this.capturePhoto())
      }
      
      if (this.saveBtn) {
        this.saveBtn.addEventListener("click", () => this.savePhoto())
      }
      
      if (this.retakeBtn) {
        this.retakeBtn.addEventListener("click", () => this.retakePhoto())
      }
    },
    capturePhoto() {
      if (!this.video || !this.canvas) return
      
      // Set canvas dimensions to match video
      this.canvas.width = this.video.videoWidth
      this.canvas.height = this.video.videoHeight
      
      // Draw video frame to canvas
      const ctx = this.canvas.getContext("2d")
      ctx.drawImage(this.video, 0, 0)
      
      // Convert to data URL
      this.capturedDataUrl = this.canvas.toDataURL("image/jpeg", 0.9)
      
      // Show preview
      if (this.previewImage) {
        this.previewImage.src = this.capturedDataUrl
      }
      if (this.previewDiv) {
        this.previewDiv.classList.remove("hidden")
      }
      
      // Stop camera stream
      this.stopCamera()
    },
    savePhoto() {
      if (!this.capturedDataUrl) {
        alert("Please capture a photo first")
        return
      }
      
      // Send to LiveView with image data
      this.pushEvent("save_captured_face", { image_data: this.capturedDataUrl })
      
      // Close modal will be handled by LiveView
    },
    retakePhoto() {
      // Hide preview
      if (this.previewDiv) {
        this.previewDiv.classList.add("hidden")
      }
      
      this.capturedDataUrl = null
      
      // Restart camera
      this.setupCamera()
    },
    stopCamera() {
      if (this.stream) {
        this.stream.getTracks().forEach(track => track.stop())
        this.stream = null
      }
      
      if (this.video) {
        this.video.srcObject = null
      }
    }
  }
}

let liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 10000,  // Increased from 2500 to 10000 for better stability
  params: {_csrf_token: csrfToken},
  hooks: Hooks
=======
let liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  params: {_csrf_token: csrfToken}
>>>>>>> f4cc723b89c09c3d7c28070dd4612ddd0b11a9bf
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

