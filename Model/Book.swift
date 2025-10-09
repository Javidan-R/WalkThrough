
import SwiftUI
//
//  Theme.swift
//  Walkthrough
//
//  Created by Abdullah on 13.08.25.
//
// MARK: - Models

// Hadith model
struct Hadith: Identifiable, Hashable {
    var id: String
    let text: String
    let narrator: String
    let source: String
}

// Ayah model (from your prompt)
struct Ayah: Identifiable, Equatable {
    var id: String
    let text: String
    let surah: String
    let verse: Int
}

// Book model (from your prompt)
struct Book: Identifiable, Equatable {
    var id: String = UUID().uuidString
    var title: String
    var author: String
    var rating: String // New
    var thumbnail: String
    var color: Color
    var description: String // New
}

let demoBooks: [Book] = [
    .init(title: "Sahih Muslim", author: "Imam Muslim", rating: "4.8", thumbnail: "sahihmuslim", color: .yellow, description: "A collection of authentic hadiths..."),
    .init(title: "Sahih al-Bukhari", author: "Imam Bukhari", rating: "4.7", thumbnail: "sahihbukhari", color: .green, description: "A collection of authentic hadiths..."),
    .init(title: "Tafsir Ibn Kathir", author: "Ibn Kathir", rating: "4.9", thumbnail: "tafsir", color: .teal, description: "A comprehensive Quran exegesis..."),
    .init(title: "The Sealed Nectar", author: "Safiur Rahman Mubarakpuri", rating: "4.7", thumbnail: "sealednectar", color: .blue, description: "Biography of the Prophet (PBUH)...")
]

let books: [Book] = [
    .init(
        title: "Sahih Muslim",
        author: "Imam Muslim",
        rating: "4.8",
        thumbnail: "sahihmuslim",
        color: .yellow,
        description: "A collection of authentic hadiths..."
    ),
    .init(
        title: "Sahih al-Bukhari",
        author: "Imam Bukhari",
        rating: "4.7",
        thumbnail: "sahihbukhari",
        color: .green,
        description: "A collection of authentic hadiths..."
    ),
    .init(
        title: "Tafsir Ibn Kathir",
        author: "Ibn Kathir",
        rating: "4.9",
        thumbnail: "tafsir",
        color: .teal,
        description: "A comprehensive Quran exegesis..."
    ),
    .init(
        title: "The Sealed Nectar",
        author: "Safiur Rahman Mubarakpuri",
        rating: "4.7",
        thumbnail: "sealednectar",
        color: .blue,
        description: "Biography of the Prophet (PBUH)..."
    )
]

// MARK: - Data

// Sample Hadith data with String IDs
let hadiths: [Hadith] = [
    Hadith(id: UUID().uuidString, text: "Bütün əməllər niyyətlərə görədir.", narrator: "Ömər ibn Xəttab", source: "Buxari"),
    Hadith(id: UUID().uuidString, text: "Bir insanın islamının gözəlliyindən biri də, onu maraqlandırmayan şeylərdən uzaq durmasıdır.", narrator: "Əbu Hureyrə", source: "Tirmizi"),
    Hadith(id: UUID().uuidString, text: "Müsəlman, müsəlmanın əlindən və dilindən salamat qaldığı kəsdir.", narrator: "Abdullah ibn Ömər", source: "Buxari, Müslim"),
    Hadith(id: UUID().uuidString, text: "Yəqin ki, mənim ümmətimdə hər yüz ildən bir dini yeniləyəcək biri gələcəkdir.", narrator: "Əbu Hureyrə", source: "Əbu Davud"),
    Hadith(id: UUID().uuidString, text: "Allah Təala buyurur ki: 'Ey Adəm övladı, Mənim ibadətimə vaxt ayır ki, sənin qəlbini zənginliklə doldurayım və ehtiyaclarını qarşılayım.", narrator: "Əbu Zərr", source: "İbn Macə"),
    Hadith(id: UUID().uuidString, text: "Allahın rəhmətinin, insanların rəhmətinə bağlı olduğunu gördüm. Allah həm öz rəhmətini o şəxsə verər ki, insanlar üçün rəhmətli olsun.", narrator: "Cabir ibn Abdullah", source: "Buxari, Ədəb-əl-Müfrəd"),
    Hadith(id: UUID().uuidString, text: "Kim ki, mənim sünnəmi (yolumu) canlandırarsa, deməli, məni sevir. Kim ki, məni sevərsə, mənimlə cənnətdə olar.", narrator: "Ənəs ibn Malik", source: "Tirmizi"),
    Hadith(id: UUID().uuidString, text: "Sizin ən yaxşınız Qur’anı öyrənən və öyrədəndir.", narrator: "Osman ibn Əffan", source: "Buxari"),
    Hadith(id: UUID().uuidString, text: "Qadınlarla mehribanlıqla davranın.", narrator: "Əbu Hureyrə", source: "Buxari, Müslim"),
    Hadith(id: UUID().uuidString, text: "Hər bir xəstəliyin bir dərmanı vardır.", narrator: "Cabir ibn Abdullah", source: "Müslim"),
    Hadith(id: UUID().uuidString, text: "Zənginlik mal-dövlətin çoxluğu ilə deyil, qəlbin zənginliyi ilədir.", narrator: "Əbu Hureyrə", source: "Buxari, Müslim"),
    Hadith(id: UUID().uuidString, text: "Həqiqətən, Allah Təala sizə səbr edən, təvazökar, razı qalan qulları sevər.", narrator: "Əbu Musa əl-Əşari", source: "Təbərani"),
    Hadith(id: UUID().uuidString, text: "Allahın Rəsulu (s.a.v) namaz qılanda sakitcə namaz qılardı.", narrator: "Ənəs ibn Malik", source: "Əhməd"),
    Hadith(id: UUID().uuidString, text: "Hər kim Allaha və Axirət gününə inanırsa, qonağına hörmət etsin.", narrator: "Əbu Hureyrə", source: "Buxari, Müslim"),
    Hadith(id: UUID().uuidString, text: "Birinizin süfrəsinə yemək düşərsə, onu qaldırıb təmizləsin, sonra yesin.", narrator: "Cabir ibn Abdullah", source: "Müslim"),
    Hadith(id: UUID().uuidString, text: "Heç biriniz özü üçün sevdiyini qardaşı üçün də sevməyincə tam mömin ola bilməz.", narrator: "Ənəs ibn Malik", source: "Buxari, Müslim"),
    Hadith(id: UUID().uuidString, text: "Sədəqə vermək yaxşılıqların ən böyüyüdür.", narrator: "Əbu Hureyrə", source: "Buxari"),
    Hadith(id: UUID().uuidString, text: "Həqiqətən, Allah təmizdir, təmizliyi sevər.", narrator: "Səhl ibn Səd", source: "Müslim"),
    Hadith(id: UUID().uuidString, text: "Həya (utanmaq) imandandır.", narrator: "Əbu Hureyrə", source: "Buxari, Müslim"),
    Hadith(id: UUID().uuidString, text: "Ən pis qadınlar, danışan, çoxlu danışan, özünü bəzəyib göstərən qadınlardır.", narrator: "Əbu Hureyrə", source: "Buxari"),
    Hadith(id: UUID().uuidString, text: "Allahın Rəsulu (s.a.v) buyurdu: 'Hər biriniz bir çobandır və rəiyyətindən məsuldur.'", narrator: "Abdullah ibn Ömər", source: "Buxari, Müslim"),
    Hadith(id: UUID().uuidString, text: "Sizin ən xeyirliniz, ailəsinə ən yaxşı davrananınızdır.", narrator: "Aişə", source: "Tirmizi"),
    Hadith(id: UUID().uuidString, text: "İki nemət var ki, insanların çoxu onlardan məhrumdur: Sağlamlıq və boş vaxt.", narrator: "Abdullah ibn Abbas", source: "Buxari"),
    Hadith(id: UUID().uuidString, text: "Bir-birinizə hədiyyə verin ki, sevginiz artsın.", narrator: "Əbu Hureyrə", source: "Buxari"),
    Hadith(id: UUID().uuidString, text: "Biriniz yuxudan oyanarkən əlini üç dəfə yumazdan qabaq qaba salmasın.", narrator: "Əbu Hureyrə", source: "Buxari, Müslim"),
    Hadith(id: UUID().uuidString, text: "Allahın rəhmətindən ümidini kəsməyin.", narrator: "Əbu Hureyrə", source: "Buxari"),
    Hadith(id: UUID().uuidString, text: "Həqiqətən, Allah hər şeyi gözəl etdi.", narrator: "Abdullah ibn Məsud", source: "Müslim"),
    Hadith(id: UUID().uuidString, text: "Kim ki, müsəlmanların işlərindən birinə görə narahat olursa, onun dərdi Allaha və Rəsuluna aiddir.", narrator: "Cabir ibn Abdullah", source: "İbn Macə"),
    Hadith(id: UUID().uuidString, text: "Bir-birinizə kin bəsləməyin, paxıllıq etməyin, ayrılmayın.", narrator: "Ənəs ibn Malik", source: "Buxari, Müslim"),
    Hadith(id: UUID().uuidString, text: "Heç biriniz öz qardaşına qəzəblənməsin.", narrator: "Əbu Hureyrə", source: "Buxari"),
    Hadith(id: UUID().uuidString, text: "Allahın Rəsulu (s.a.v) deyirdi: 'Allahım, Səndən faydalı elm, halal ruzi və qəbul olunmuş əməl istəyirəm.'", narrator: "Ümmü Sələmə", source: "İbn Macə"),
    Hadith(id: UUID().uuidString, text: "Kim ki, bir müsəlmanın ayıbını örtərsə, Allah da Qiyamət günü onun ayıbını örtər.", narrator: "Abdullah ibn Abbas", source: "Buxari"),
    Hadith(id: UUID().uuidString, text: "Yaxşılıq gözəl əxlaqdır. Günah isə, sənin qəlbində şübhə doğuran və insanların bilməsini xoşlamadığın şeydir.", narrator: "Ən-Nəvvas ibn Səm'an", source: "Müslim"),
    Hadith(id: UUID().uuidString, text: "Mömin möminin güzgüsüdür.", narrator: "Əbu Hureyrə", source: "Əbu Davud"),
    Hadith(id: UUID().uuidString, text: "Sizin ən xeyirliniz, insanlara faydalı olanınızdır.", narrator: "Cabir ibn Abdullah", source: "Təbərani"),
    Hadith(id: UUID().uuidString, text: "Allah hər şeyə qadirdir.", narrator: "Əbu Hureyrə", source: "Buxari"),
    Hadith(id: UUID().uuidString, text: "Birinizin namazı bitdikdə, üç dəfə 'Sübhanəllah' desin.", narrator: "Əbu Zərr", source: "Müslim"),
    Hadith(id: UUID().uuidString, text: "Allahın rəhməti ananın rəhmətindən böyükdür.", narrator: "Cabir ibn Abdullah", source: "Buxari, Müslim"),
    Hadith(id: UUID().uuidString, text: "Kim ki, namazını tərk edərsə, Allahdan uzaqlaşmışdır.", narrator: "Əbu Hureyrə", source: "Tirmizi"),
    Hadith(id: UUID().uuidString, text: "Sizin ən xeyirliniz, borcunu ən gözəl şəkildə qaytarandır.", narrator: "Cabir ibn Abdullah", source: "Buxari"),
    Hadith(id: UUID().uuidString, text: "Allah Təala hər bir xeyir işi sevər.", narrator: "Ənəs ibn Malik", source: "İbn Hibban"),
    Hadith(id: UUID().uuidString, text: "Heç biriniz öz qardaşının satışı üstünə satış etməsin.", narrator: "Cabir ibn Abdullah", source: "Müslim"),
    Hadith(id: UUID().uuidString, text: "Kim ki, bir yolda gedər, Allah onun üçün Cənnətə bir yol asanlaşdırar.", narrator: "Əbu Hureyrə", source: "Müslim"),
    Hadith(id: UUID().uuidString, text: "Allahın yanında ən sevimli əməllər, az olsa da davamlı olanlardır.", narrator: "Aişə", source: "Buxari, Müslim"),
    Hadith(id: UUID().uuidString, text: "Mömin yüngül və yumşaqdır.", narrator: "Cabir ibn Abdullah", source: "Tirmizi"),
    Hadith(id: UUID().uuidString, text: "Birinizin namaz qılarkən arxasına baxması, onun namazını pozar.", narrator: "Əbu Hureyrə", source: "Buxari"),
    Hadith(id: UUID().uuidString, text: "Allah Təala buyurur ki: 'Sizin ibadətiniz mənim üçün fərq etməz.'", narrator: "Əbu Səid əl-Xudri", source: "Tirmizi"),
    Hadith(id: UUID().uuidString, text: "Ən çox günah edən kimsə, ən çox yalan danışan kimsədir.", narrator: "Əbu Hureyrə", source: "Tirmizi"),
    Hadith(id: UUID().uuidString, text: "Birinizin bir qardaşına yardım etməsi, bir-birindən ayrılmaması daha yaxşıdır.", narrator: "Ənəs ibn Malik", source: "Buxari"),
    Hadith(id: UUID().uuidString, text: "Allah rəhmət edər, o şəxsə ki, bir şeyə görə razı qalar və rəğbət edər.", narrator: "Cabir ibn Abdullah", source: "Əhməd"),
    Hadith(id: UUID().uuidString, text: "Ən böyük günah, Allahdan başqasına ibadət etmək və valideynə qarşı gəlməkdir.", narrator: "Əbu Bəkrah", source: "Buxari"),
    Hadith(id: UUID().uuidString, text: "Kim ki, qardaşının ehtiyacını ödəyərsə, Allah da onun ehtiyacını ödəyər.", narrator: "Abdullah ibn Ömər", source: "Buxari, Müslim"),
    Hadith(id: UUID().uuidString, text: "Sizin ən xeyirliniz, xeyir əməlləri yerinə yetirməkdə tələsəndir.", narrator: "Ənəs ibn Malik", source: "Tirmizi"),
    Hadith(id: UUID().uuidString, text: "Qəlbini pak saxla ki, Allah sənə gözəl əxlaq bəxş etsin.", narrator: "Əli ibn Əbu Talib", source: "İbn Hibban"),
    Hadith(id: UUID().uuidString, text: "Allah-Təala buyurur ki: 'Mən zəif qulların duasını qəbul edərəm.'", narrator: "Əbu Hureyrə", source: "Əbu Davud"),
    Hadith(id: UUID().uuidString, text: "Müsəlmanın müsəlmana qarşı dörd haqqı var: onun qeybətini etməmək, onu aldatmamaq, onu tərk etməmək və ona nifrət etməmək.", narrator: "Səhl ibn Səd", source: "Müslim"),
    Hadith(id: UUID().uuidString, text: "Cənnət anaların ayaqları altındadır.", narrator: "Ənəs ibn Malik", source: "Nəsai"),
    Hadith(id: UUID().uuidString, text: "Allahın sizə olan rəhmətini əldən verməyin.", narrator: "Cabir ibn Abdullah", source: "Buxari"),
    Hadith(id: UUID().uuidString, text: "Ən fəzilətli cihad zalım hökmdar qarşısında deyilən haqq sözdür.", narrator: "Əbu Səid əl-Xudri", source: "Tirmizi"),
    Hadith(id: UUID().uuidString, text: "Təmizlik imanın yarısıdır.", narrator: "Əbu Malik əl-Əşari", source: "Müslim")
]

// Sample Ayah data
let ayahs: [Ayah] = [
    Ayah(id: UUID().uuidString, text: "Alif, Lam, Ra. This is a Book which We have revealed to you, [O Muhammad], that you might bring mankind out of darknesses into the light by permission of their Lord - to the path of the Exalted in Might, the Praiseworthy -", surah: "Ibrahim", verse: 1),
    Ayah(id: UUID().uuidString, text: "The month of Ramadhan [is that] in which was revealed the Qur'an, a guidance for the people and clear proofs of guidance and criterion. So whoever sights [the new moon of] the month, let him fast it; and whoever is ill or on a journey - then an equal number of other days. Allah intends for you ease and does not intend for you hardship and [wants] for you to complete the period and to glorify Allah for that [to] which He has guided you; and perhaps you will be grateful.", surah: "Al-Baqarah", verse: 185)
]
