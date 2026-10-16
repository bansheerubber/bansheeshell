pragma Singleton

import Quickshell
import QtQuick
import Quickshell.Io

Singleton {
    PersistentProperties {
        id: persistentState
        
        property var data
        property int lastFetch: 0
    }

    property int temperature: {
        if (!persistentState.data) {
            return 0;
        }

        return persistentState.data.current.temp;
    }

    property string icon: {
        if (!persistentState.data) {
            return "";
        }

        const id = persistentState.data.current.weather[0].id;
        const highClouds = persistentState.data.current.clouds;
        const isDay = true;

        if (200 <= id && id <= 202) {
            if (highClouds) {
                return "thunderstorms-rain";
            } else if (isDay) {
                return "thunderstorms-day-rain";
            } else {
                return "thunderstorms-night-rain";
            }
        } else if ((210 <= id && id <= 212) || id == 221 || (230 <= id && id <= 232)) {
            if (highClouds) {
                return "thunderstorms";
            } else if (isDay) {
                return "thunderstorms-day";
            } else {
                return "thunderstorms-night";
            }
        } else if ((300 <= id && id <= 302) || id == 313 || id == 314 || id == 321) {
            if (highClouds) {
                return "drizzle";
            } else if (isDay) {
                return "partly-cloudy-day-drizzle";
            } else {
                return "partly-cloudy-night-drizzle";
            }
        } else if ((310 <= id && id <= 312) || (500 <= id && id <= 504) || id == 511 || (520 <= id && id <= 522) || id == 530) {
            if (highClouds) {
                return "rain";
            } else if (isDay) {
                return "partly-cloudy-day-rain";
            } else {
                return "partly-cloudy-night-rain";
            }
        } else if ((600 <= id && id <= 602) || id == 615 || id == 616 || (620 <= id && id <= 622)) {
            if (highClouds) {
                return "snow";
            } else if (isDay) {
                return "partly-cloudy-day-snow";
            } else {
                return "partly-cloudy-night-snow";
            }
        } else if (611 <= id && id <= 613) {
            if (highClouds) {
                return "sleet";
            } else if (isDay) {
                return "partly-cloudy-day-sleet";
            } else {
                return "partly-cloudy-night-sleet";
            }
        } else if (id == 701) {
            return "mist";
        } else if (id == 711) {
            if (highClouds) {
                return "smoke";
            } else if (isDay) {
                return "partly-cloudy-day-smoke";
            } else {
                return "partly-cloudy-night-smoke";
            }
        } else if (id == 721) {
            if (highClouds) {
                return "haze";
            } else if (isDay) {
                return "haze-day";
            } else {
                return "haze-night";
            }
        } else if (id == 731 || id == 751 || id == 761) {
            if (highClouds) {
                return "dust";
            } else if (isDay) {
                return "dust-day";
            } else {
                return "dust-night";
            }
        } else if (id == 741) {
            if (highClouds) {
                return "fog";
            } else if (isDay) {
                return "fog-day";
            } else {
                return "fog-night";
            }
        } else if (id == 762) {
            return "volcano";
        } else if (id == 771) {
            return "wind";
        } else if (id == 781) {
            return "tornado";
        } else if (id == 800) {
            if (isDay) {
                return "clear-day";
            } else {
                return "clear-night";
            }
        } else if (id == 801 || id == 802) {
            if (isDay) {
                return "partly-cloudy-day";
            } else {
                return "partly-cloudy-night";
            }
        } else if (id == 803) {
            return "cloudy";
        } else if (id == 804) {
            return "overcast";
        }

        return "";
    }

    FileView {
        id: weatherApiToken
        path: Qt.resolvedUrl("./weather-token")
        blockLoading: true
    }

    Process {
        id: weatherFetch

        command: [
            "curl",
            `https://api.openweathermap.org/data/3.0/onecall?lat=47.6038321&lon=-122.330062&exclude=minutely,alerts&appid=${weatherApiToken.text().trim()}&units=imperial`
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                console.log("Weather fetched");

                try {
                    persistentState.data = JSON.parse(this.text);
                } catch (error) {
                    console.error("Failed to fetch", this.text);
                }
            }
        }
    }

    Timer {
        interval: 600 * 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if (Date.now() / 1000 - persistentState.lastFetch < 600) {
                return;
            }

            weatherFetch.running = true 
            persistentState.lastFetch = Date.now() / 1000;
        }
    }
}
