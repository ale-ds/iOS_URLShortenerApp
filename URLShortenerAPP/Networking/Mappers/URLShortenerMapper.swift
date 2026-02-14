import Foundation

struct URLShortenerMapper {
    static func map(dto: AliasResponseDTO) -> ShortenedURL {
        return ShortenedURL(
            alias: dto.alias,
            originalURL: dto.links.selfURL,
            shortURL: dto.links.short
        )
    }
}
