import React from 'react';
import ReactNative from 'react-native';

const StyleSheet = ReactNative.StyleSheet;
const Text = ReactNative.Text;
const View = ReactNative.View;

export default class ClosedHours extends React.Component {

  // noinspection JSUnusedGlobalSymbols
  static propTypes = {
    day: React.PropTypes.object.isRequired,
    isCurrent: React.PropTypes.bool.isRequired,
  };

  render() {
    const day = this.props.day;
    if (day.breaks.length > 0) {
      const lineHeight = this.props.isCurrent ? 14 : 13;
      const breaksHeight = { height: (day.breaks.length * lineHeight) + 5 };
      const textStyle = this.props.isCurrent ? styles.currentDayBreaksText : styles.breaksText;
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
}

const styles = StyleSheet.create({
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
});
