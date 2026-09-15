import Foundation

struct WeatherSnapshot {
    let temperatureCelsius: Double
    let humidityPercent: Double
}

/// Open-Meteo - free, no API key or account required. Used instead of
/// WeatherKit so this works without an Apple Developer Program enrollment.
enum WeatherAPI {
    private struct Response: Decodable {
        struct Current: Decodable {
            let temperature_2m: Double
            let relative_humidity_2m: Double
        }
        let current: Current
    }

    static func currentWeather(latitude: Double, longitude: Double) async throws -> WeatherSnapshot {
        var components = URLComponents(string: "https://api.open-meteo.com/v1/forecast")!
        components.queryItems = [
            URLQueryItem(name: "latitude", value: String(latitude)),
            URLQueryItem(name: "longitude", value: String(longitude)),
            URLQueryItem(name: "current", value: "temperature_2m,relative_humidity_2m"),
        ]
        guard let url = components.url else { throw APIError.invalidResponse }
        let (data, _) = try await URLSession.shared.data(from: url)
        let decoded = try JSONDecoder().decode(Response.self, from: data)
        return WeatherSnapshot(
            temperatureCelsius: decoded.current.temperature_2m,
            humidityPercent: decoded.current.relative_humidity_2m
        )
    }
}
