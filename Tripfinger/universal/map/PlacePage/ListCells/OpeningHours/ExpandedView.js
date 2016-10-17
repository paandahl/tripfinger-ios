import React from 'react';
import ReactNative from 'react-native';
import ClosedHours from './ClosedHours';

const StyleSheet = ReactNative.StyleSheet;
const Text = ReactNative.Text;
const View = ReactNative.View;

export default class ExpandedView extends React.Component {

  // noinspection JSUnusedGlobalSymbols
  static propTypes = {
    expanded: React.PropTypes.bool.isRequired,
    weekdays: React.PropTypes.array.isRequired,
    closedDays: React.PropTypes.string,
  };

  _renderClosedDays() {
    if (this.props.closedDays) {
      return (
        <View key="closed" style={styles.weekday}>
          <Text style={styles.weekdayText}>{this.props.closedDays}</Text>
          <Text style={styles.weekdayValue}>Closed</Text>
        </View>
      );
    }
    return null;
  }

  render() {
    if (this.props.expanded) {
      return (
        <View style={styles.expandedView}>
          {this.props.weekdays.map(day =>
            <View key={day.label} style={styles.weekday}>
              <View style={styles.weekdayOpenHours}>
                <Text style={styles.weekdayText}>{day.label}</Text>
                <Text style={styles.weekdayValue}>{day.openTime}</Text>
              </View>
              <ClosedHours day={day} isCurrent={false} />
            </View>
          )}
          {this._renderClosedDays()}
        </View>
      );
    }
    return null;
  }
}

const styles = StyleSheet.create({
  expandedView: {
    borderTopWidth: 1,
    borderTopColor: '#f3f3f3',
    marginRight: 40,
    paddingTop: 5,
    paddingBottom: 5,
  },
  weekday: {
    marginTop: 5,
  },
  weekdayOpenHours: {
    height: 20,
  },
  weekdayText: {
    color: '#777',
  },
  weekdayValue: {
    color: '#777',
    position: 'absolute',
    left: 100,
    top: 0,
  },
});
