import UIKit
import FlickrCore

class ImagesViewController: UIViewController {

    let queryService = QueryService(query: "Hot")
    let datasource = ImageViewDatasource()
    @IBOutlet var collectionView: UICollectionView!


    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = datasource
        collectionView.delegate = self
        getImages()
    }

    func getImages() {
        queryService.nextImages(onSuccess: { [weak self] (photos) in
            guard let collectionView = self?.collectionView else { return }
            self?.datasource.add(photos: photos, to: collectionView)
        }) { (error) in
            dump(error)
        }
    }
}

extension ImagesViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width / 3 - 5
        return CGSize(width: width, height: width)
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let scrollingEndThreshold = 50
        let offset = scrollView.contentOffset.y + scrollView.bounds.height
        if (offset > scrollView.contentSize.height - CGFloat(scrollingEndThreshold)) {
            getImages()
        }
    }
}
