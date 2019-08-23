import Foundation

class FakeResponseData {
    // MARK: - Data
    static var bookCorrectData: Data? {
        let bundle = Bundle(for: FakeResponseData.self)
        let url = bundle.url(forResource: "Book", withExtension: "json")!
        return try! Data(contentsOf: url)
    }

    static let bookIncorrectData = "erreur".data(using: .utf8)!

    // MARK: - Response
    static let responseOK = HTTPURLResponse(
        url: URL(string: "https://openclassrooms.com")!,
        statusCode: 200, httpVersion: nil, headerFields: [:])!

    static let responseKO = HTTPURLResponse(
        url: URL(string: "https://openclassrooms.com")!,
        statusCode: 500, httpVersion: nil, headerFields: [:])!

    // MARK: - Error
    class BookError: Error {}
    static let error = BookError()
}

