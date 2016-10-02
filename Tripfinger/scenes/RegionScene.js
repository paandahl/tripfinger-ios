// <editor-fold desc="Imports">
import React from 'react';
import ReactNative from 'react-native';
import GuideItemCell from '../components/GuideItemCell';

const Component = React.Component;
const PropTypes = React.PropTypes;
const ListView = ReactNative.ListView;
const StyleSheet = ReactNative.StyleSheet;
const Text = ReactNative.Text;
// </editor-fold>

export default class RegionScene extends Component {

  // noinspection JSUnusedGlobalSymbols
  static propTypes = {
    region: PropTypes.shape({}),
  };

  // noinspection JSUnusedGlobalSymbols
  static title(props) {
    return props.region.name;
  }

  constructor(props) {
    super(props);
    // noinspection JSUnusedGlobalSymbols
    const ds = new ListView.DataSource({
      rowHasChanged: (r1, r2) => r1 !== r2,
      sectionHeaderHasChanged: (s1, s2) => s1 !== s2,
    });
    this.state = {
      dataSource: ds.cloneWithRowsAndSections({ guideItem: [true] }, ['guideItem']),
    };
  }

  renderRow = (data, sectionId) => {
    if (sectionId === 'guideItem') {
      return <GuideItemCell region={this.props.region} />;
    } else if (sectionId === 'attractions') {
      return <Text>{data}</Text>;
    }
    return <Text>{data}</Text>;
  };
  //   (
  //     <TouchableHighlight
  //       key={country.uuid}
  //       style={styles.row}
  //       underlayColor="#DDDDDD"
  //       onPressIn={() => highlightRow(sectionId, rowId)}
  //       onPressOut={() => highlightRow(null)}
  //       onPress={() => this.navigateToCountry(country)}
  //     >
  //       <View style={styles.innerRow}>
  //         <Text style={styles.rowText}>{country.name}</Text>
  //       </View>
  //     </TouchableHighlight>
  //   );
  // }

  render() {
    return (
      <ListView
        dataSource={this.state.dataSource}
        renderRow={this.renderRow}
        style={styles.list}
      />
    );
  }
}

const styles = StyleSheet.create({
  list: {
    backgroundColor: '#EBEBF1',
  },
});
