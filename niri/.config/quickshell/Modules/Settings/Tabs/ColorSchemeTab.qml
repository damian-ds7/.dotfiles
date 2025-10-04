import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Io
import qs.Commons
import qs.Services
import qs.Widgets

ColumnLayout {
  id: root

  // Cache for scheme JSON (can be flat or {dark, light})
  property var schemeColorsCache: ({})

  // Scale properties for card animations
  property real cardScaleLow: 0.95
  property real cardScaleHigh: 1.0

  spacing: Style.marginL * scaling

  // Helper function to extract scheme name from path
  function extractSchemeName(schemePath) {
    var pathParts = schemePath.split("/")
    var filename = pathParts[pathParts.length - 1] // Get filename
    var schemeName = filename.replace(".json", "") // Remove .json extension

    // Convert folder names back to display names
    if (schemeName === "Noctalia-default") {
      schemeName = "Noctalia (default)"
    } else if (schemeName === "Noctalia-legacy") {
      schemeName = "Noctalia (legacy)"
    } else if (schemeName === "Tokyo-Night") {
      schemeName = "Tokyo Night"
    }

    return schemeName
  }

  // Helper function to get color from scheme file (supports dark/light variants)
  function getSchemeColor(schemePath, colorKey) {
    // Extract scheme name from path
    var schemeName = extractSchemeName(schemePath)

    // Try to get from cached data first
    if (schemeColorsCache[schemeName]) {
      var entry = schemeColorsCache[schemeName]
      var variant = entry
      if (entry.dark || entry.light) {
        variant = Settings.data.colorSchemes.darkMode ? (entry.dark || entry.light) : (entry.light || entry.dark)
      }
      if (variant && variant[colorKey])
        return variant[colorKey]
    }

    // Return a default color if not cached yet
    return "#000000"
  }

  // This function is called by the FileView Repeater when a scheme file is loaded
  function schemeLoaded(schemeName, jsonData) {
    var value = jsonData || {}
    var newCache = schemeColorsCache
    newCache[schemeName] = value
    schemeColorsCache = newCache
  }

  // When the list of available schemes changes, clear the cache.
  // The Repeater below will automatically re-create the FileViews.
  Connections {
    target: ColorSchemeService
    function onSchemesChanged() {
      schemeColorsCache = {}
    }
  }

  // Simple process to check if matugen exists
  Process {
    id: matugenCheck
    command: ["which", "matugen"]
    running: false

    onExited: function (exitCode) {
      if (exitCode === 0) {
        // Matugen exists, enable it
        Settings.data.colorSchemes.useWallpaperColors = true
        MatugenService.generateFromWallpaper()
        ToastService.showNotice(I18n.tr("settings.color-scheme.color-source.use-wallpaper-colors.label"), I18n.tr("toast.wallpaper-colors.enabled"))
      } else {
        // Matugen not found
        ToastService.showWarning(I18n.tr("settings.color-scheme.color-source.use-wallpaper-colors.label"), I18n.tr("toast.wallpaper-colors.not-installed"))
      }
    }

    stdout: StdioCollector {}
    stderr: StdioCollector {}
  }

  // A non-visual Item to host the Repeater that loads the color scheme files.
  Item {
    visible: false
    id: fileLoaders

    Repeater {
      model: ColorSchemeService.schemes

      // The delegate is a Component, which correctly wraps the non-visual FileView
      delegate: Item {
        FileView {
          path: modelData
          blockLoading: true
          onLoaded: {
            // Extract scheme name from path
            var schemeName = extractSchemeName(path)

            try {
              var jsonData = JSON.parse(text())
              root.schemeLoaded(schemeName, jsonData)
            } catch (e) {
              Logger.warn("ColorSchemeTab", "Failed to parse JSON for scheme:", schemeName, e)
              root.schemeLoaded(schemeName, null) // Load defaults on parse error
            }
          }
        }
      }
    }
  }

  // Main Toggles - Dark Mode / Matugen
  NHeader {
    label: I18n.tr("settings.color-scheme.color-source.section.label")
    description: I18n.tr("settings.color-scheme.color-source.section.description")
  }

  // Dark Mode Toggle (affects both Matugen and predefined schemes that provide variants)
  NToggle {
    label: I18n.tr("settings.color-scheme.color-source.dark-mode.label")
    description: I18n.tr("settings.color-scheme.color-source.dark-mode.description")
    checked: Settings.data.colorSchemes.darkMode
    enabled: true
    onToggled: checked => Settings.data.colorSchemes.darkMode = checked
  }

  // Use Wallpaper Colors
  NToggle {
    label: I18n.tr("settings.color-scheme.color-source.use-wallpaper-colors.label")
    description: I18n.tr("settings.color-scheme.color-source.use-wallpaper-colors.description")
    checked: Settings.data.colorSchemes.useWallpaperColors
    onToggled: checked => {
                 if (checked) {
                   // Check if matugen is installed
                   matugenCheck.running = true
                 } else {
                   Settings.data.colorSchemes.useWallpaperColors = false
                   ToastService.showNotice(I18n.tr("settings.color-scheme.color-source.use-wallpaper-colors.label"), I18n.tr("toast.wallpaper-colors.disabled"))

                   if (Settings.data.colorSchemes.predefinedScheme) {

                     ColorSchemeService.applyScheme(Settings.data.colorSchemes.predefinedScheme)
                   }
                 }
               }
  }

  // Matugen Scheme Type Selection
  NComboBox {
    label: I18n.tr("settings.color-scheme.color-source.matugen-scheme-type.label")
    description: I18n.tr("settings.color-scheme.color-source.matugen-scheme-type.description")
    enabled: Settings.data.colorSchemes.useWallpaperColors
    opacity: Settings.data.colorSchemes.useWallpaperColors ? 1.0 : 0.6
    visible: Settings.data.colorSchemes.useWallpaperColors

    model: [{
        "key": "scheme-content",
        "name": "Content"
      }, {
        "key": "scheme-expressive",
        "name": "Expressive"
      }, {
        "key": "scheme-fidelity",
        "name": "Fidelity"
      }, {
        "key": "scheme-fruit-salad",
        "name": "Fruit Salad"
      }, {
        "key": "scheme-monochrome",
        "name": "Monochrome"
      }, {
        "key": "scheme-neutral",
        "name": "Neutral"
      }, {
        "key": "scheme-rainbow",
        "name": "Rainbow"
      }, {
        "key": "scheme-tonal-spot",
        "name": "Tonal Spot"
      }]

    currentKey: Settings.data.colorSchemes.matugenSchemeType

    onSelected: key => {
                  Settings.data.colorSchemes.matugenSchemeType = key
                  if (Settings.data.colorSchemes.useWallpaperColors) {
                    MatugenService.generateFromWallpaper()
                  }
                }
  }

  NDivider {
    Layout.fillWidth: true
    Layout.topMargin: Style.marginXL * scaling
    Layout.bottomMargin: Style.marginXL * scaling
    visible: !Settings.data.colorSchemes.useWallpaperColors
  }

  // Predefined Color Schemes
  ColumnLayout {
    spacing: Style.marginM * scaling
    Layout.fillWidth: true
    visible: !Settings.data.colorSchemes.useWallpaperColors

    NHeader {
      label: I18n.tr("settings.color-scheme.predefined.section.label")
      description: I18n.tr("settings.color-scheme.predefined.section.description")
    }

    // Generate templates for predefined schemes
    NCheckbox {
      Layout.fillWidth: true
      label: I18n.tr("settings.color-scheme.predefined.generate-templates.label")
      description: I18n.tr("settings.color-scheme.predefined.generate-templates.description")
      checked: Settings.data.colorSchemes.generateTemplatesForPredefined
      onToggled: checked => {
                   Settings.data.colorSchemes.generateTemplatesForPredefined = checked
                   // Re-generate templates if a predefined scheme is currently active
                   if (!Settings.data.colorSchemes.useWallpaperColors && Settings.data.colorSchemes.predefinedScheme) {
                     ColorSchemeService.applyScheme(Settings.data.colorSchemes.predefinedScheme)
                   }
                 }
      Layout.bottomMargin: Style.marginL * scaling
    }

    // Color Schemes Grid
    GridLayout {
      columns: 6
      rowSpacing: Style.marginL * scaling
      columnSpacing: Style.marginL * scaling
      Layout.fillWidth: true

      Repeater {
        model: ColorSchemeService.schemes

        ColumnLayout {
          id: schemeItem

          property string schemePath: modelData

          Layout.alignment: Qt.AlignHCenter
          spacing: Style.marginS * scaling

          // Circular color preview with surface background and accent dots
          Rectangle {
            id: circularPreview

            Layout.alignment: Qt.AlignHCenter
            width: 80 * scaling
            height: 80 * scaling
            radius: width * 0.5
            color: getSchemeColor(modelData, "mSurface")
            border.width: Math.max(2, Style.borderL * scaling)
            border.color: (!Settings.data.colorSchemes.useWallpaperColors && (Settings.data.colorSchemes.predefinedScheme === extractSchemeName(modelData))) ? Color.mSecondary : Color.mOutline
            scale: root.cardScaleLow

            // Four small color dots arranged in a circle to show accent colors
            Item {
              id: colorDots
              anchors.centerIn: parent
              width: parent.width * 0.6
              height: parent.height * 0.6

              // Rotation animation for the fidget spinner effect
              rotation: 0

              Behavior on rotation {
                NumberAnimation {
                  duration: 3000
                  easing.type: Easing.InOutQuad
                }
              }

              // Primary color dot (top)
              Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: -2 * scaling
                width: 18 * scaling
                height: 18 * scaling
                radius: width * 0.5
                color: getSchemeColor(modelData, "mPrimary")
                border.width: Math.max(1, Style.borderS * scaling)
                border.color: getSchemeColor(modelData, "mSurface")
              }

              // Secondary color dot (right)
              Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                anchors.rightMargin: -2 * scaling
                width: 18 * scaling
                height: 18 * scaling
                radius: width * 0.5
                color: getSchemeColor(modelData, "mSecondary")
                border.width: Math.max(1, Style.borderS * scaling)
                border.color: getSchemeColor(modelData, "mSurface")
              }

              // Tertiary color dot (bottom)
              Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: -2 * scaling
                width: 18 * scaling
                height: 18 * scaling
                radius: width * 0.5
                color: getSchemeColor(modelData, "mTertiary")
                border.width: Math.max(1, Style.borderS * scaling)
                border.color: getSchemeColor(modelData, "mSurface")
              }

              // Error color dot (left)
              Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: -2 * scaling
                width: 18 * scaling
                height: 18 * scaling
                radius: width * 0.5
                color: getSchemeColor(modelData, "mError")
                border.width: Math.max(1, Style.borderS * scaling)
                border.color: getSchemeColor(modelData, "mSurface")
              }
            }

            MouseArea {
              anchors.fill: parent
              onClicked: {
                Settings.data.colorSchemes.useWallpaperColors = false
                Logger.log("ColorSchemeTab", "Disabled matugen setting")

                Settings.data.colorSchemes.predefinedScheme = extractSchemeName(schemePath)
                ColorSchemeService.applyScheme(Settings.data.colorSchemes.predefinedScheme)
              }
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor

              onEntered: {
                circularPreview.scale = root.cardScaleHigh
                // circles go spin
                colorDots.rotation += 360
              }

              onExited: {
                circularPreview.scale = root.cardScaleLow
                // circles don't go spin anymore :(
                colorDots.rotation = 0
              }
            }

            // Selection indicator
            Rectangle {
              visible: !Settings.data.colorSchemes.useWallpaperColors && (Settings.data.colorSchemes.predefinedScheme === extractSchemeName(schemePath))
              anchors.right: parent.right
              anchors.top: parent.top
              anchors.rightMargin: 3 * scaling
              anchors.topMargin: 3 * scaling
              width: 20 * scaling
              height: 20 * scaling
              radius: width * 0.5
              color: Color.mSecondary
              border.width: Math.max(1, Style.borderS * scaling)
              border.color: Color.mOnSecondary

              NIcon {
                icon: "check"
                pointSize: Style.fontSizeXS * scaling
                font.weight: Style.fontWeightBold
                color: Color.mOnSecondary
                anchors.centerIn: parent
              }
            }

            // Smooth animations
            Behavior on scale {
              NumberAnimation {
                duration: Style.animationNormal
                easing.type: Easing.OutCubic
              }
            }

            Behavior on border.color {
              ColorAnimation {
                duration: Style.animationNormal
              }
            }

            Behavior on border.width {
              NumberAnimation {
                duration: Style.animationFast
              }
            }
          }

          // Scheme name below the circle
          NText {
            text: extractSchemeName(schemePath)
            pointSize: Style.fontSizeS * scaling
            font.weight: Style.fontWeightMedium
            color: Color.mOnSurface
            Layout.fillWidth: true
            Layout.maximumWidth: 100 * scaling
            Layout.preferredHeight: 40 * scaling // Fixed height for consistent alignment
            elide: Text.ElideRight
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            wrapMode: Text.WordWrap
            maximumLineCount: 2
          }
        }
      }
    }
  }
}
