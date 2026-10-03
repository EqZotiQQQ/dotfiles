import QtQuick

// Row on a horizontal bar, column on a vertical one (Theme.barVertical); items centered across it
Grid {
    columns: Theme.barVertical ? 1 : 1000
    horizontalItemAlignment: Grid.AlignHCenter
    verticalItemAlignment: Grid.AlignVCenter
}
