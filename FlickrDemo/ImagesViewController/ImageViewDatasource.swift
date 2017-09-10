import Foundation
import UIKit
import FlickrCore

class ImageViewDatasource: NSObject, UICollectionViewDataSource {

    private var photos = [Photo]()

    func add(photos: [Photo], to collectionView: UICollectionView) {
        let indexPaths = createIndexPaths(from: self.photos.count, forNext: photos.count)
        self.photos.append(contentsOf: photos)
        collectionView.insertItems(at: indexPaths)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let imageViewCell = ImageViewCell.fromCollectionView(collectionView, for: indexPath)
        imageViewCell.download(photo: photos[indexPath.row])
        return imageViewCell
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }

    private func createIndexPaths(from: Int, forNext numberOfItems: Int) -> [IndexPath] {
        var indexPaths = [IndexPath]()
        for index in from..<from+numberOfItems {
            indexPaths.append(IndexPath(row: index, section: 0))
        }
        return indexPaths
    }
}

class ImageViewCell: UICollectionViewCell {
    private static let cellIdentifier = "ImageViewCellIdentifier"
    @IBOutlet var imageView: UIImageView!
    private var photo: Photo?

    class func fromCollectionView(_ collectionView: UICollectionView,
                                  for indexPath: IndexPath) -> ImageViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier,
                                                      for: indexPath)
        guard let imageViewCell = cell as? ImageViewCell else {
            fatalError("Please make sure that UICollectionView cell has a cell registered with \(cellIdentifier)")
        }
        return imageViewCell
    }

    func download(photo newPhoto: Photo) {
        self.imageView.image = nil
        self.photo?.cancel()
        newPhoto.download(on: imageView)
        self.photo = newPhoto
    }
}
