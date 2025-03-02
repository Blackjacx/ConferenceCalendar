#!/usr/bin/env swift

import Foundation

// Converts conferences JSON file into a nice markdown

let fileManager = FileManager.default

do {
    let jsonPath = try determineInputFile()
    let conferencesByYear = try parseJson(at: jsonPath)
    let markdown = try generateMarkdown(conferencesByYear: conferencesByYear)
    print(markdown)
} catch {
    print(error)
}

/// Determine JSON data file
func determineInputFile() throws -> String {
    let scriptUrl: URL = {
        let cwdUrl = URL(fileURLWithPath: fileManager.currentDirectoryPath)
        let scriptPath = CommandLine.arguments[0]
        return URL(fileURLWithPath: scriptPath, relativeTo: cwdUrl).absoluteURL
    }()

    let jsonPath = URL(
        fileURLWithPath: "../resources/data.json",
        relativeTo: scriptUrl
    ).absoluteURL.path()

    guard fileManager.fileExists(atPath: jsonPath) else {
        throw ScriptError.fileNotFound(jsonPath)
    }

    return jsonPath
}

/// Parses the JSON input data object
func parseJson(at path: String) throws -> [String: [Conference]] {
    guard let data = FileManager.default.contents(atPath: path) else {
        throw ScriptError.fileNotFound(path)
    }

    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    decoder.allowsJSON5 = true
    decoder.dateDecodingStrategy = .custom { decoder in
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate, .withDashSeparatorInDate]
        guard let date = formatter.date(from: string) else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Cannot decode date string \(string)"
            )
        }
        return date
    }

    do {
        let dataWrapper: DataWrapper<[String: [Conference]]> = try decoder.decode(
            DataWrapper<[String: [Conference]]>.self,
            from: data
        )
        return dataWrapper.object
    } catch {
        throw ScriptError.jsonConversionFailed(underlyingError: error)
    }
}

func generateMarkdown(conferencesByYear: [String: [Conference]]) throws -> String {
    var out = [
        "# Conference Calendar",
        "This site lists interesting tech conferences throughout the year(s) including most important related information.",
        "## Contribution",
        "If you want to contribute, please fork the repo and create a pull request from `main` to your branch. I will review your changes and merge them.",
    ]

    // https://goshdarnformatstyle.com/date-range-styles/
    let dateStyle = Date.IntervalFormatStyle().day().month().year()

    for (year, conferences) in conferencesByYear {
        out += ["## \(year)"]

        for conference in conferences {
            let twitter = conference.twitter.map { "[X (former Twitter)](https://x.com/\($0))" }
            let mastodon = conference.mastodon.map { "[Mastodon](\($0))" }
            let bluesky = conference.bluesky.map { "[Bluesky](https://bsky.app/profile/\($0))" }
            let dates = if let dateRange = conference.dateRange {
                dateStyle.format(dateRange)
            } else {
                "n/a"
            }
            let location = conference.location
            let pricing = if conference.tickets.isEmpty {
                "n/a"
            } else {
                {
                    let items = conference.tickets.map { "<li>\($0.formattedPrice) - \($0.name)</li>" }
                    let itemsString = items.joined(separator: "")
                    return "<ul> \(itemsString) </ul>"
                }()
            }
            out += [
                """
                ### [\(conference.name)](\(conference.url)) 

                \([twitter, mastodon, bluesky].compactMap { $0 }.joined(separator: " • "))

                \(conference.description)

                <table>
                    <tr>
                        <th>Dates</th> <th>Location</th> <th>Pricing</th>
                    </tr>
                    <tr>
                        <td>\(dates)</td> <td>\(location)</td> <td>\(pricing)</td>
                    </tr>
                </table>
                """,
            ]
        }
    }

    return out.joined(separator: "\n\n")
}

// MARK: - Helper Types

enum ScriptError: Error {
    case fileNotFound(_ path: String)
    case jsonConversionFailed(underlyingError: Error)
}

struct Conference: Codable {
    var name: String
    var description: String
    var url: URL
    var twitter: String?
    var bluesky: String?
    var mastodon: String?
    var dateRange: Range<Date>?
    var location: String
    var tickets: [Ticket]

    static func < (lhs: Conference, rhs: Conference) -> Bool {
        guard let lhsDateRange = lhs.dateRange, let rhsDateRange = rhs.dateRange else {
            return false
        }
        return lhsDateRange.lowerBound < rhsDateRange.lowerBound
    }
}

struct Ticket: Hashable, Equatable, Comparable, Codable {
    var name: String
    var value: Int
    var currency: Currency

    static func < (lhs: Ticket, rhs: Ticket) -> Bool {
        return lhs.value < rhs.value
    }

    var formattedPrice: String {
        guard value > 0 else {
            return "Free 🤑"
        }
        return value.formatted(
            .currency(code: currency.isoCode)
                .scale(currency.multiplier)
        )
    }
}

// swiftlint:disable:next type_body_length
enum Currency: String, CaseIterable, Codable {
    case aed = "AED"
    case afn = "AFN"
    case all = "ALL"
    case amd = "AMD"
    case ang = "ANG"
    case aoa = "AOA"
    case ars = "ARS"
    case aud = "AUD"
    case awg = "AWG"
    case azn = "AZN"
    case bam = "BAM"
    case bbd = "BBD"
    case bdt = "BDT"
    case bgn = "BGN"
    case bhd = "BHD"
    case bif = "BIF"
    case bmd = "BMD"
    case bnd = "BND"
    case bob = "BOB"
    case bov = "BOV"
    case brl = "BRL"
    case bsd = "BSD"
    case btn = "BTN"
    case bwp = "BWP"
    case byn = "BYN"
    case bzd = "BZD"
    case cad = "CAD"
    case cdf = "CDF"
    case che = "CHE"
    case chf = "CHF"
    case chw = "CHW"
    case clf = "CLF"
    case clp = "CLP"
    case cny = "CNY"
    case cop = "COP"
    case cou = "COU"
    case crc = "CRC"
    case cuc = "CUC"
    case cup = "CUP"
    case cve = "CVE"
    case czk = "CZK"
    case djf = "DJF"
    case dkk = "DKK"
    case dop = "DOP"
    case dzd = "DZD"
    case egp = "EGP"
    case ern = "ERN"
    case etb = "ETB"
    case eur = "EUR"
    case fjd = "FJD"
    case fkp = "FKP"
    case gbp = "GBP"
    case gel = "GEL"
    case ghs = "GHS"
    case gip = "GIP"
    case gmd = "GMD"
    case gnf = "GNF"
    case gtq = "GTQ"
    case gyd = "GYD"
    case hkd = "HKD"
    case hnl = "HNL"
    case hrk = "HRK"
    case htg = "HTG"
    case huf = "HUF"
    case idr = "IDR"
    case ils = "ILS"
    case inr = "INR"
    case iqd = "IQD"
    case irr = "IRR"
    case isk = "ISK"
    case jmd = "JMD"
    case jod = "JOD"
    case jpy = "JPY"
    case kes = "KES"
    case kgs = "KGS"
    case khr = "KHR"
    case kmf = "KMF"
    case kpw = "KPW"
    case krw = "KRW"
    case kwd = "KWD"
    case kyd = "KYD"
    case kzt = "KZT"
    case lak = "LAK"
    case lbp = "LBP"
    case lkr = "LKR"
    case lrd = "LRD"
    case lsl = "LSL"
    case lyd = "LYD"
    case mad = "MAD"
    case mdl = "MDL"
    case mga = "MGA"
    case mkd = "MKD"
    case mmk = "MMK"
    case mnt = "MNT"
    case mop = "MOP"
    case mru = "MRU"
    case mur = "MUR"
    case mvr = "MVR"
    case mwk = "MWK"
    case mxn = "MXN"
    case mxv = "MXV"
    case myr = "MYR"
    case mzn = "MZN"
    case nad = "NAD"
    case ngn = "NGN"
    case nio = "NIO"
    case nok = "NOK"
    case npr = "NPR"
    case nzd = "NZD"
    case omr = "OMR"
    case pab = "PAB"
    case pen = "PEN"
    case pgk = "PGK"
    case php = "PHP"
    case pkr = "PKR"
    case pln = "PLN"
    case pyg = "PYG"
    case qar = "QAR"
    case ron = "RON"
    case rsd = "RSD"
    case rub = "RUB"
    case rwf = "RWF"
    case sar = "SAR"
    case sbd = "SBD"
    case scr = "SCR"
    case sdg = "SDG"
    case sek = "SEK"
    case sgd = "SGD"
    case shp = "SHP"
    case sll = "SLL"
    case sos = "SOS"
    case srd = "SRD"
    case ssp = "SSP"
    case stn = "STN"
    case svc = "SVC"
    case syp = "SYP"
    case szl = "SZL"
    case thb = "THB"
    case tjs = "TJS"
    case tmt = "TMT"
    case tnd = "TND"
    case top = "TOP"
    case `try` = "TRY"
    case ttd = "TTD"
    case twd = "TWD"
    case tzs = "TZS"
    case uah = "UAH"
    case ugx = "UGX"
    case usd = "USD"
    case uyi = "UYI"
    case uyu = "UYU"
    case uzs = "UZS"
    case vef = "VEF"
    case vnd = "VND"
    case vuv = "VUV"
    case wst = "WST"
    case xcd = "XCD"
    case yer = "YER"
    case zar = "ZAR"
    case zmw = "ZMW"
    case zwl = "ZWL"

    var isoCode: String { rawValue }

    var multiplier: Double {
        let minorUnit: Int = switch self {
        case .aed: 2
        case .afn: 2
        case .all: 2
        case .amd: 2
        case .ang: 2
        case .aoa: 2
        case .ars: 2
        case .aud: 2
        case .awg: 2
        case .azn: 2
        case .bam: 2
        case .bbd: 2
        case .bdt: 2
        case .bgn: 2
        case .bhd: 3
        case .bif: 0
        case .bmd: 2
        case .bnd: 2
        case .bob: 2
        case .bov: 2
        case .brl: 2
        case .bsd: 2
        case .btn: 2
        case .bwp: 2
        case .byn: 2
        case .bzd: 2
        case .cad: 2
        case .cdf: 2
        case .che: 2
        case .chf: 2
        case .chw: 2
        case .clf: 4
        case .clp: 0
        case .cny: 2
        case .cop: 2
        case .cou: 2
        case .crc: 2
        case .cuc: 2
        case .cup: 2
        case .cve: 2
        case .czk: 2
        case .djf: 0
        case .dkk: 2
        case .dop: 2
        case .dzd: 2
        case .egp: 2
        case .ern: 2
        case .etb: 2
        case .eur: 2
        case .fjd: 2
        case .fkp: 2
        case .gbp: 2
        case .gel: 2
        case .ghs: 2
        case .gip: 2
        case .gmd: 2
        case .gnf: 0
        case .gtq: 2
        case .gyd: 2
        case .hkd: 2
        case .hnl: 2
        case .hrk: 2
        case .htg: 2
        case .huf: 2
        case .idr: 2
        case .ils: 2
        case .inr: 2
        case .iqd: 3
        case .irr: 2
        case .isk: 0
        case .jmd: 2
        case .jod: 3
        case .jpy: 0
        case .kes: 2
        case .kgs: 2
        case .khr: 2
        case .kmf: 0
        case .kpw: 2
        case .krw: 0
        case .kwd: 3
        case .kyd: 2
        case .kzt: 2
        case .lak: 2
        case .lbp: 2
        case .lkr: 2
        case .lrd: 2
        case .lsl: 2
        case .lyd: 3
        case .mad: 2
        case .mdl: 2
        case .mga: 2
        case .mkd: 2
        case .mmk: 2
        case .mnt: 2
        case .mop: 2
        case .mru: 2
        case .mur: 2
        case .mvr: 2
        case .mwk: 2
        case .mxn: 2
        case .mxv: 2
        case .myr: 2
        case .mzn: 2
        case .nad: 2
        case .ngn: 2
        case .nio: 2
        case .nok: 2
        case .npr: 2
        case .nzd: 2
        case .omr: 3
        case .pab: 2
        case .pen: 2
        case .pgk: 2
        case .php: 2
        case .pkr: 2
        case .pln: 2
        case .pyg: 0
        case .qar: 2
        case .ron: 2
        case .rsd: 2
        case .rub: 2
        case .rwf: 0
        case .sar: 2
        case .sbd: 2
        case .scr: 2
        case .sdg: 2
        case .sek: 2
        case .sgd: 2
        case .shp: 2
        case .sll: 2
        case .sos: 2
        case .srd: 2
        case .ssp: 2
        case .stn: 2
        case .svc: 2
        case .syp: 2
        case .szl: 2
        case .thb: 2
        case .tjs: 2
        case .tmt: 2
        case .tnd: 3
        case .top: 2
        case .try: 2
        case .ttd: 2
        case .twd: 2
        case .tzs: 2
        case .uah: 2
        case .ugx: 0
        case .usd: 2
        case .uyi: 0
        case .uyu: 2
        case .uzs: 2
        case .vef: 2
        case .vnd: 0
        case .vuv: 0
        case .wst: 2
        case .xcd: 2
        case .yer: 2
        case .zar: 2
        case .zmw: 2
        case .zwl: 2
        }
        return pow(Double(10), Double(-minorUnit))
    }
}

struct DataWrapper<T: Codable>: Codable {
    let object: T

    // MARK: - Sub-Types

    enum CodingKeys: String, CodingKey {
        case object = "data"
    }
}
