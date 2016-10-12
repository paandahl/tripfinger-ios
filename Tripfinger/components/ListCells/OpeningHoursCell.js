import React from 'react';
import ReactNative from 'react-native';
import Globals from '../../modules/Globals';

const Image = ReactNative.Image;
const StyleSheet = ReactNative.StyleSheet;
const Text = ReactNative.Text;
const TouchableHighlight = ReactNative.TouchableHighlight;
const View = ReactNative.View;
const openHoursIcon = require('../../assets/placepage/open_hours.png');
const arrowUpIcon = require('../../assets/placepage/arrow_up.png');
const arrowDownIcon = require('../../assets/placepage/arrow_down.png');

export default class OpeningHoursCell extends React.Component {

  // noinspection JSUnusedGlobalSymbols
  static propTypes = {
    openingHours: React.PropTypes.object.isRequired,
  };

  static _renderBreaks(day, currentDay = false) {
    if (day.breaks.length > 0) {
      const lineHeight = currentDay ? 14 : 13;
      const breaksHeight = { height: (day.breaks.length * lineHeight) + 5 };
      const textStyle = currentDay ? styles.currentDayBreaksText : styles.breaksText;
      return (
        <View key={`${day.label}-breaks`} style={breaksHeight}>
          <Text style={textStyle}>Hours Closed</Text>
          <View style={styles.breaks}>
            {day.breaks.map(breakHours =>
              <Text key={`${day.label}-brk-${breakHours}`} style={textStyle}>{breakHours}</Text>
            )}
          </View>
        </View>
      );
    }
    return null;
  }

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

  _renderClosedDays() {
    if (this.props.openingHours.closedDays) {
      return (
        <View key="closed" style={styles.weekday}>
          <Text style={styles.weekdayText}>{this.props.openingHours.closedDays}</Text>
          <Text style={styles.weekdayValue}>Closed</Text>
        </View>
      );
    }
    return null;
  }

  _renderExpandedView() {
    if (this.state.expanded) {
      return (
        <View style={styles.expandedView}>
          {this.props.openingHours.weekdays.map(day =>
            <View key={day.label} style={styles.weekday}>
              <View style={styles.weekdayOpenHours}>
                <Text style={styles.weekdayText}>{day.label}</Text>
                <Text style={styles.weekdayValue}>{day.openTime}</Text>
              </View>
              {OpeningHoursCell._renderBreaks(day)}
            </View>
          )}
          {this._renderClosedDays()}
        </View>
      );
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
        {OpeningHoursCell._renderBreaks(hours.currentDay, true)}
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
            {this._renderExpandedView()}
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
  firstRowInSection: {
    marginTop: 20,
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
  rowHighlight: {
    flex: 1,
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
  breaksContainer: {
    paddingBottom: 10,
  },
  breaks: {
    position: 'absolute',
    left: 100,
    top: 0,
  },
  breaksText: {
    color: '#888',
    fontSize: 12,
  },
  currentDayBreaksText: {
    color: '#777',
    fontSize: 13,
  },
  closedText: {
    fontSize: 13,
    color: Globals.colors.cancelRed,
    paddingBottom: 10,
  },
});
