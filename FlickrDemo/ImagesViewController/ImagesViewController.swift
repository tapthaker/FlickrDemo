import UIKit
import FlickrCore

class ImagesViewController: UIViewController {

    var queryService: QueryService!

    @IBOutlet private var collectionView: UICollectionView!
    private let imagesDatasource = ImageViewDatasource()

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = imagesDatasource
        collectionView.delegate = self
        getImages()

    }

    class func forQuery(_ query: String) -> ImagesViewController {
        let queryService = QueryService(query: query)
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ImageViewController") as! ImagesViewController
        viewController.queryService = queryService
        return viewController
    }

    private func getImages() {
        queryService.nextImages(onSuccess: { [weak self] (photos) in
            guard let collectionView = self?.collectionView else { return }
            self?.imagesDatasource.add(photos: photos, to: collectionView)
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
