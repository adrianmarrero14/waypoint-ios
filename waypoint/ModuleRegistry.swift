import HabitsFeature
import TasksFeature
import WaypointCore
import WaypointFeature

enum ModuleRegistry {
    static let all: [ModuleDescriptor] = [
        WaypointModule.descriptor,
        HabitsModule.descriptor,
        TasksModule.descriptor,
    ]
}
