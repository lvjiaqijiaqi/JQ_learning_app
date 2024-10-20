import SwiftUI

struct JQ_ConfigureContentView: View {
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: JQ_TagManagementView()) {
                    Label("标签管理", systemImage: "tag")
                }
                // 在这里可以添加更多配置选项
            }
            .navigationTitle("设置")
        }
    }
}
