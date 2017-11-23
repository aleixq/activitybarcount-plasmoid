/***********************************************************************
 * Copyright 2013 Bhushan Shah <bhush94@gmail.com>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 ***********************************************************************/

import QtQuick 2.0
import QtQuick.Layouts 1.1
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.activities 0.1 as Activities
import org.kde.taskmanager 0.1 as TaskManager


Item {
  id: root
  Layout.minimumWidth: tabBar.contentWidth
  Layout.minimumHeight: tabBar.implicitHeight
  Plasmoid.preferredRepresentation: Plasmoid.fullRepresentation
  
  //     RowLayout{
  //         id: activityBar
  //         anchors.fill: parent
  PlasmaComponents.TabBar {
    id: tabBar
    anchors.fill: parent
    position: {
      switch (plasmoid.location) {
        case PlasmaCore.Types.LeftEdge:
          return Qt.LeftEdge;
        case PlasmaCore.Types.RightEdge:
          return Qt.RightEdge;
        case PlasmaCore.Types.TopEdge:
          return Qt.TopEdge;
        default:
          return Qt.BottomEdge;
      }
    }
    Activities.ActivityModel {
      id: activityModel
      shownStates: "Running"
    }
    Repeater {
      id: activities
      model: PlasmaCore.SortFilterModel {
        id: activeWindowModel
        //filterRole: 'IsActive'
        //filterRegExp: 'true'
        sourceModel: activityModel
      }
      delegate: PlasmaComponents.TabButton {
        id: tab
        checked: model.current
        visible: tasksModel.count > 0
        width: tasksModel.count > 0 ? implicitWidth : 0
        height: tabBar.height
        onClicked: {
          activityModel.setCurrentActivity(model.id, function() {});
        }
        contentItem:
        GridLayout{
          anchors.fill: parent
          id: tabLayout
          columns: 1
          rows: 1
          property bool portrait: root.height >= activityLabel.paintedHeight + units.iconSizes.small
          flow: portrait ? GridLayout.LeftToRight : GridLayout.TopToBottom
          PlasmaCore.IconItem{
            id: activityIcon
            source: model.icon
            implicitHeight: units.iconSizes.small
            width: height
            Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
          }
          PlasmaComponents.Label{
            id: activityLabel
            text: model.name + '\n<br /><small>' + tasksModel.count + ' '+ i18n('tasks') + '</small>'
            textFormat:Text.RichText 
            Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
            //Layout.preferredWidth: tabLayout.portrait ? tab.width : implicitWidth
            //Layout.preferredHeight: tabLayout.portrait ? implicitHeight : tab.height
            //elide: Text.ElideRight
            horizontalAlignment: !tabLayout.portrait && activityIcon.source != null ? Text.AlignLeft : Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
          }
        }
        TaskManager.TasksModel {
          id: tasksModel
          //sortMode: TaskManager.TasksModel.SortVirtualDesktop
          //groupMode: TaskManager.TasksModel.GroupDisabled
          activity: model.id
          filterByActivity: true
          screenGeometry: plasmoid.screenGeometry
          onActiveTaskChanged: {}
          onDataChanged: {}
          onCountChanged: {}
        }
        PlasmaCore.ToolTipArea {
          id: tooltip
          mainText: model.name + ' ' + tasksModel.count + ' ' + i18n('tasks')
          anchors.fill: parent
          interactive: true
          visible: tasksModel.count > 0
          mainItem: ListView{
            id: tasksList
            width: contentItem.childrenRect.width
            height: contentItem.childrenRect.height
            model: tasksModel
            delegate:
            PlasmaComponents.ToolButton{
              // RoleNames at libtaskmanager/abstracttasksmodel.h
              height: taskDelegateIcon.height
              anchors.left: parent.left
              anchors.right: parent.right
              width:taskRow.width + taskRow.spacing
              onClicked:{tasksModel.requestActivate(tasksModel.makeModelIndex(index))}
              Row{
                id: taskRow
                spacing: 3
                PlasmaCore.IconItem{
                  id: taskDelegateIcon
                  source: model.decoration
                  height: units.iconSizes.large
                  width: height
                }
                PlasmaComponents.Label{
                  id: appLabel
                  text: model.display
                }
              }
            }
          }
        }
      }
    }
  }
  PlasmaCore.DataSource {
    id: dataSource
    engine: "org.kde.activities"
    connectedSources: [activeSource]
  }
  Component.onCompleted: {
    plasmoid.removeAction("configure");
    plasmoid.setAction("activities", "activities", "preferences-activities", null);
  }
  function action_activities(){
    var service = dataSource.serviceForSource("Status")
    var operation = service.operationDescription("toggleActivityManager")
    service.startOperationCall(operation)
  }
}
