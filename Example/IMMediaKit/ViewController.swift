import Combine
import IMMediaKit
import UIKit

/// 按 USAGE 走通：导入图片、按日期分组列出、加载缩略图、打开图片编辑器（IMMediaKit/Editing）。
final class ViewController: UITableViewController {

    private var groups: [IMMediaGroup] = []
    private var subscription: AnyCancellable?

    init() { super.init(style: .insetGrouped) }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "IMMediaKit"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "导入", style: .plain,
                                                            target: self, action: #selector(importSample))
        tableView.register(MediaCell.self, forCellReuseIdentifier: "media")
        subscription = IMMediaSDK.shared.events.sink { [weak self] _ in self?.reload() }
        reload()
    }

    private func reload() {
        groups = IMMediaSDK.shared.fetchGrouped(query: .allFirstPage)
        tableView.reloadData()
    }

    @objc private func importSample() {
        let hue = CGFloat.random(in: 0...1)
        let image = UIGraphicsImageRenderer(size: CGSize(width: 600, height: 400)).image { ctx in
            UIColor(hue: hue, saturation: 0.6, brightness: 0.9, alpha: 1).setFill()
            ctx.fill(CGRect(x: 0, y: 0, width: 600, height: 400))
            ("IMMediaKit" as NSString).draw(at: CGPoint(x: 40, y: 170),
                                            withAttributes: [.font: UIFont.boldSystemFont(ofSize: 56),
                                                             .foregroundColor: UIColor.white])
        }
        IMMediaSDK.shared.importImage(image) { _ in }
    }

    override func numberOfSections(in tableView: UITableView) -> Int { groups.count + 1 }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        section == 0 ? "资源" : groups[section - 1].key.rawValue
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? 1 : groups[section - 1].items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
            cell.textLabel?.text = "IMMediaKitEditing.bundle"
            cell.detailTextLabel?.text = Bundle.main.url(forResource: "IMMediaKitEditing", withExtension: "bundle") == nil ? "未找到" : "已找到"
            cell.selectionStyle = .none
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "media", for: indexPath) as! MediaCell
        cell.bind(groups[indexPath.section - 1].items[indexPath.row])
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard indexPath.section > 0,
              let image = UIImage(contentsOfFile: groups[indexPath.section - 1].items[indexPath.row].localPath) else { return }
        IMImageEditor.shared.present(image: image, from: self, persist: true) { _ in }
    }
}

private final class MediaCell: UITableViewCell {

    private var token: IMImageRequestToken?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        accessoryType = .disclosureIndicator
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func bind(_ item: IMMediaItem) {
        textLabel?.text = "\(item.type) \(item.width ?? 0)×\(item.height ?? 0)"
        detailTextLabel?.text = ByteCountFormatter.string(fromByteCount: item.fileSize, countStyle: .file)
        imageView?.image = UIImage(systemName: "photo")
        let request = IMImageRequest(item: item, targetSize: CGSize(width: 88, height: 88))
        token = IMMediaSDK.shared.loadImage(request) { [weak self] image in
            guard let image else { return }
            self?.imageView?.image = image
            self?.setNeedsLayout()
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        token?.cancel()
    }
}
