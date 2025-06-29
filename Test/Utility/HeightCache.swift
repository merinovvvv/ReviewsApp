import Foundation

final class HeightCache {
    private var cache: [String: CGFloat] = [:]

    func getHeight(for key: String) -> CGFloat? {
        assert(Thread.isMainThread, "Height cache должен использоваться только на главном потоке")
        return cache[key]
    }

    func setHeight(_ height: CGFloat, for key: String) {
        assert(Thread.isMainThread, "Height cache должен использоваться только на главном потоке")
        cache[key] = height
    }

    func clearCache() {
        assert(Thread.isMainThread, "Height cache должен использоваться только на главном потоке")
        cache.removeAll()
    }
}
