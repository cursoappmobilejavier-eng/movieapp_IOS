//
//  UIImageViewExtensions.swift
//  MovieApp-iOS
//
//  Created by Mananas on 3/12/25.
//

import UIKit

private final class ImageCache {
    static let shared = ImageCache()
    let cache = NSCache<NSURL, UIImage>()
    private init() {}
}

private var associatedURLKey: UInt8 = 0
private var associatedTaskKey: UInt8 = 0

extension UIImageView {

    // Última URL solicitada para esta imageView (para evitar condiciones de carrera en celdas)
    private var currentImageURL: URL? {
        get { objc_getAssociatedObject(self, &associatedURLKey) as? URL }
        set { objc_setAssociatedObject(self, &associatedURLKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    // Task asociada para poder cancelarla en reutilización
    private var currentLoadTask: Task<Void, Never>? {
        get { objc_getAssociatedObject(self, &associatedTaskKey) as? Task<Void, Never> }
        set { objc_setAssociatedObject(self, &associatedTaskKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    /// Cancela cualquier descarga en curso asociada a esta imageView.
    func cancelImageLoad() {
        currentLoadTask?.cancel()
        currentLoadTask = nil
        currentImageURL = nil
    }

    /// Carga una imagen desde URL segura con caché y cancelación.
    /// - Parameters:
    ///   - url: URL remota.
    ///   - placeholder: Imagen a mostrar mientras carga.
    func loadFrom(url: URL, placeholder: UIImage? = nil) {
        // Asignar placeholder inmediatamente (en main)
        if Thread.isMainThread {
            self.image = placeholder
        } else {
            DispatchQueue.main.async { [weak self] in self?.image = placeholder }
        }

        // Cancelar tarea anterior si existiera
        cancelImageLoad()

        currentImageURL = url

        // Revisar caché primero
        if let cached = ImageCache.shared.cache.object(forKey: url as NSURL) {
            DispatchQueue.main.async { [weak self] in
                // Asegurar que sigue siendo la URL actual
                guard let self, self.currentImageURL == url else { return }
                self.image = cached
            }
            return
        }

        // Crear nueva task de carga
        let task = Task { [weak self] in
            guard let self else { return }
            do {
                let (data, response) = try await URLSession.shared.data(from: url)
                // Validar respuesta HTTP 200-299
                if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
                    return
                }
                guard !Task.isCancelled else { return }
                guard let image = UIImage(data: data) else { return }

                // Guardar en caché
                ImageCache.shared.cache.setObject(image, forKey: url as NSURL)

                // Asignar si sigue siendo la misma URL solicitada
                await MainActor.run { [weak self] in
                    guard let self, self.currentImageURL == url else { return }
                    self.image = image
                }
            } catch {
                // Silencioso o puedes añadir logs si lo deseas
                // debugPrint("Image load error for \(url):", error)
            }
        }

        currentLoadTask = task
    }

    /// Acepta string y valida "N/A" o vacío.
    func loadFrom(url: String, placeholder: UIImage? = nil) {
        let trimmed = url.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, trimmed.uppercased() != "N/A", let url = URL(string: trimmed) else {
            // URL inválida: cancelar y poner placeholder o nil
            cancelImageLoad()
            if Thread.isMainThread {
                self.image = placeholder
            } else {
                DispatchQueue.main.async { [weak self] in self?.image = placeholder }
            }
            return
        }
        loadFrom(url: url, placeholder: placeholder)
    }
}
