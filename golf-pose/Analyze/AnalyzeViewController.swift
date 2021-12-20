//
//  AnalyzeViewController.swift
//  golf-pose
//
//  Created by 이동현 on 2021/12/12.
//

import UIKit
import AVFoundation
import RxSwift
import RxCocoa
import SnapKit
import Then
import ScreenCorners
import ReactorKit
import RxDataSources

class AnalyzeViewController: UIViewController, View {

    private let tableView = UITableView().then {
        $0.register(ResultCell.self, forCellReuseIdentifier: ResultCell.reuseIdentifier)
        $0.register(TitleCell.self, forCellReuseIdentifier: TitleCell.reuseIdentifier)
        $0.register(PlayerCell.self, forCellReuseIdentifier: PlayerCell.reuseIdentifier)
        $0.register(ButtonCell.self, forCellReuseIdentifier: ButtonCell.reuseIdentifier)
        $0.contentInsetAdjustmentBehavior = .automatic
        $0.separatorStyle = .none
        $0.backgroundColor = .black
    }

    var disposeBag = DisposeBag()
    let sourceURL: URL

    override func viewDidLoad() {
        super.viewDidLoad()

        configure()
        reactor = MainViewReactor()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    init(sourceURL: URL, result: String) {
        self.sourceURL = sourceURL
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    private func configure() {
        view.backgroundColor = .black
        view.addSubview(tableView)

        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }


    func bind(reactor: MainViewReactor) {
        let dataSource = RxTableViewSectionedReloadDataSource<Section>(
          configureCell: { [weak self] dataSource, tableView, indexPath, item in
              guard let self = self else {
                  return UITableViewCell()
              }
              switch item {
              case .detail(let improvement):
                  let cell = tableView.dequeueReusableCell(withIdentifier: ResultCell.reuseIdentifier, for: indexPath) as! ResultCell
                  cell.setResult(improvement)
                  return cell
              case .title(let title):
                  let cell = tableView.dequeueReusableCell(withIdentifier: TitleCell.reuseIdentifier, for: indexPath) as! TitleCell
                  cell.setTitle(title)
                  return cell
              case .player(let result):
                  let cell = tableView.dequeueReusableCell(withIdentifier: PlayerCell.reuseIdentifier, for: indexPath) as! PlayerCell
                  cell.setResult(url: self.sourceURL, title: result.title, start: result.startFrame, end: result.endFrame)
                  return cell
              case .button:
                  let cell = tableView.dequeueReusableCell(withIdentifier: ButtonCell.reuseIdentifier, for: indexPath)
                  return cell
              }
        })

        Observable.just(DTOResult.mock)
            .map { result in
                var cellTypes: [CellType] = [.title("Good \(result.title)!!")]
                cellTypes += result.details.flatMap { detail -> [CellType] in
                    [.player(detail)] + detail.improvements.map { .detail($0) }
                }
                cellTypes.append(.button)
                return [Section(items: cellTypes)]
            }
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        tableView.rx.modelSelected(CellType.self)
            .subscribe(onNext: { [weak self] cellType in
                switch cellType {
                case .button:
                    self?.dismiss(animated: true, completion: nil)
                default:
                    break
                }
            })
            .disposed(by: disposeBag)
    }
}

enum CellType {
    case detail(Improvement)
    case title(String)
    case player(DTOResultDetail)
    case button
}
struct Section {
    var items: [CellType]
}
extension Section: SectionModelType {
    typealias Item = CellType

    init(original: Section, items: [CellType]) {
        self = original
        self.items = items
    }
}
