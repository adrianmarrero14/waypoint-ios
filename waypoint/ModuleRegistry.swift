import HabitsFeature
import LogbookFeature
import TasksFeature
import WaypointCore

enum ModuleRegistry {
    static let all: [ModuleDescriptor] = [
        HabitsModule.descriptor,
        TasksModule.descriptor,
        LogbookModule.descriptor,
    ]
}
