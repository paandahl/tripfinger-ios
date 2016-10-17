import React from 'react';
import ReactNative from 'react-native';
import Globals from '../../../../shared/Globals';
import ClosedHours from './ClosedHours';
import ExpandedView from './ExpandedView';

const Image = ReactNative.Image;
const StyleSheet = ReactNative.StyleSheet;
const Text = ReactNative.Text;
const TouchableHighlight = ReactNative.TouchableHighlight;
const View = ReactNative.View;
const openHoursIcon = require('../../../../../assets/placepage/open_hours.png');
const arrowUpIcon = require('../../../../../assets/placepage/arrow_up.png');
const arrowDownIcon = require('../../../../../assets/placepage/arrow_down.png');

export default class OpeningHoursCell extends React.Component {

  // noinspection JSUnusedGlobalSymbols
  static propTypes = {
    openingHours: React.PropTypes.object.isRequired,
  };

  static _renderClosedText(day) {
    if (day.closed) {
      return <Text style={styles.closedText}>Closed now</Text>;
    }
    return null;
  }

  constructor() {
    super();
    this.state = {
      expanded: false,
    };
  }

  _expandable() {
    return this.props.openingHours.weekdays.length !== 0;
  }

  _toggleExpand = () => {
    if (this._expandable()) {
      this.setState({ expanded: !this.state.expanded });
    }
  };

  _renderExpandIcon() {
    if (this._expandable()) {
      if (this.state.expanded) {
        return <Image style={styles.expandIcon} source={arrowUpIcon} />;
      }
      return <Image style={styles.expandIcon} source={arrowDownIcon} />;
    }
    return null;
  }

  _renderCurrentDay() {
    const hours = this.props.openingHours;
    if (hours.plainText) {
      return <View style={styles.currentDay}><Text>{hours.plainText}</Text></View>;
    }
    return (
      <View style={styles.currentDay}>
        <View style={styles.currentDayHeader}>
          <Text style={styles.rowLabel}>{hours.currentDay.label}</Text>
          <Text style={styles.rowValue}>{hours.currentDay.openTime}</Text>
          {this._renderExpandIcon()}
        </View>
        <ClosedHours day={hours.currentDay} isCurrent />
        {OpeningHoursCell._renderClosedText(hours.currentDay)}
      </View>
    );
  }

  render() {
    return (
      <TouchableHighlight
        key="openingHours"
        style={styles.row}
        underlayColor="#DDDDDD"
        onPress={this._toggleExpand}
      >
        <View style={styles.container}>
          <Image style={styles.icon} source={openHoursIcon} />
          <View style={styles.innerRow}>
            {this._renderCurrentDay()}
            <ExpandedView
              expanded={this.state.expanded} weekdays={this.props.openingHours.weekdays}
              closedDays={this.props.openingHours.closedDays}
            />
          </View>
        </View>
      </TouchableHighlight>
    );
  }
}

const styles = StyleSheet.create({
  row: {
    paddingLeft: 15,
    backgroundColor: '#FFFFFF',
  },
  container: {
    paddingLeft: 40,
    alignItems: 'center',
    flexDirection: 'row',
  },
  icon: {
    position: 'absolute',
    tintColor: '#5D5D5D',
    top: 11,
    left: 0,
  },
  innerRow: {
    flex: 1,
    borderBottomWidth: 1,
    borderBottomColor: '#eee',
  },
  currentDayHeader: {
    height: 46,
    flexDirection: 'row',
    alignSelf: 'stretch',
    alignItems: 'center',
  },
  rowLabel: {
    fontSize: 16,
  },
  rowValue: {
    position: 'absolute',
    left: 100,
    top: 13,
    fontSize: 16,
  },
  expandIcon: {
    position: 'absolute',
    right: 10,
    top: 10,
    tintColor: '#5D5D5D',
  },
  closedText: {
    fontSize: 13,
    color: Globals.colors.cancelRed,
    paddingBottom: 10,
  },
});
