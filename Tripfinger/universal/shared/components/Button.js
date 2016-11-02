import React from 'react';
import ReactNative from 'react-native';

const StyleSheet = ReactNative.StyleSheet;
const TouchableHighlight = ReactNative.TouchableHighlight;
const View = ReactNative.View;

export default function Button({ style = {}, onPress, children }) {
  return (
    <TouchableHighlight style={[styles.button, style]} onPress={onPress}>
      <View style={styles.buttonView}>
        {children}
      </View>
    </TouchableHighlight>
  );
}

// noinspection JSUnusedGlobalSymbols
Button.propTypes = {
  style: React.PropTypes.any,
  onPress: React.PropTypes.func,
  children: React.PropTypes.any,
};

const styles = StyleSheet.create({
  button: {
    alignItems: 'center',
    padding: 15,
    marginBottom: 20,
    width: 200,
    borderWidth: 1,
    borderRadius: 10,
  },
  buttonView: {
    alignItems: 'center',
  },
});
