

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var editButton: UIBarButtonItem!
   
    
    var doneButton : UIBarButtonItem?
    
    var tasks = [Task](){
        didSet {
            self.saveTasks()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTap))
        self.doneButton?.tintColor = .darkGray
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.loadTasks()
    }
    
    @objc func doneButtonTap(){
        self.navigationItem.leftBarButtonItem = editButton
        self.tableView.setEditing(false, animated: true)
    }

    @IBAction func tapEditButton(_ sender: UIBarButtonItem) {
        guard !self.tasks.isEmpty else { return }
        self.navigationItem.leftBarButtonItem = doneButton
        self.tableView.setEditing(true, animated: true)
    }
    
    @IBAction func tapAddButton(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: " 할일을 입력하세요 ", message: nil, preferredStyle: .alert)
        let registerButton = UIAlertAction(title: "확인", style: .default, handler: { [weak self]_ in
            // debugPrint("\(alert.textFields?[0].text)")
            guard let title = alert.textFields?[0].text else { return }
            let task = Task(title: title, done: false)
            self?.tasks.append(task)
            self?.tableView.reloadData()
        })
        let cancelButton = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        alert.addAction(cancelButton)
        alert.addAction(registerButton)
        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = nil
        })
        self.present(alert, animated: true, completion: nil)
    }
    
    func saveTasks() {
        let data = self.tasks.map{
            [
                "title": $0.title,
                "done": $0.done
            ]
        }
        let userDefaults = UserDefaults.standard
        userDefaults.set(data, forKey: "tasks")
    }
    
    func loadTasks() {
        let userDefaults = UserDefaults.standard
        guard let data = userDefaults.object(forKey: "tasks") as? [[String: Any]] else { return }
        self.tasks = data.compactMap {
            guard let title = $0["title"] as? String else {return nil}
            guard let done = $0["done"] as? Bool else {return nil}
            return Task(title: title, done: done)
        }
    }
}


extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let task = self.tasks[indexPath.row]

       
        let attributeString = NSMutableAttributedString(string: task.title)
        if task.done {
            attributeString.addAttribute(
                NSAttributedString.Key.strikethroughStyle,
                value: NSUnderlineStyle.single.rawValue,
                range: NSRange(location: 0, length: attributeString.length)
            )
        }

        cell.textLabel?.attributedText = attributeString
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        self.tasks.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        
        if self.tasks.isEmpty {
            self.doneButtonTap()
        }
    }
}

//수정파트
extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let task = self.tasks[indexPath.row]
        
        // 알림창 생성
        let alert = UIAlertController(title: "할 일 수정", message: "수정할 내용을 입력하세요", preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "수정", style: .default) { [unowned self] _ in
            // 텍스트 필드에서 수정된 텍스트소환
            if let textField = alert.textFields?.first, let newText = textField.text, !newText.isEmpty {
                // 할 일을 수정
                self.tasks[indexPath.row].title = newText
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
                // 수정된 할 일 저장
                self.saveTasks()
            }
        }
        
        // 취소 버튼 생성
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        
        //현재 작성된 할 일 표시
        alert.addTextField { textField in
            textField.text = task.title
        }
        
        // 버튼을 추가
        alert.addAction(confirmAction)
        alert.addAction(cancelAction)
        
        // 알림창 표시
        present(alert, animated: true)
    }
}

