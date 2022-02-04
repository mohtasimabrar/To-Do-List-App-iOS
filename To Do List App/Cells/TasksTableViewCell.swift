//
//  TasksTableViewCell.swift
//  To Do List App
//
//  Created by BS236 on 3/2/22.
//

import UIKit

class TasksTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func cellConfiguration (_ task:Task){
        titleLabel.text = task.title
        subtitleLabel.text = task.task
    }

}
