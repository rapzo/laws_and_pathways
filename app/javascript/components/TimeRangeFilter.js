import React, { Fragment, Component } from 'react';
import PropTypes from 'prop-types';
import Select from 'react-select';
import { Range, Handle } from 'rc-slider';
import minus from '../../assets/images/icons/dark-minus.svg';
import plus from '../../assets/images/icons/dark-plus.svg';


const blueDarkColor = '#2E3152';
const redColor = '#ED3D48';
const greyColor = '#9698A8';

const customStyles = {
  option: (provided, state) => ({
    ...provided,
    color: blueDarkColor,
    backgroundColor: state.isSelected ? 'inherit' : 'inherit'
  }),
  control: (provided, state) => ({
    ...provided,
    borderRadius: 0,
    borderColor: state.isFocused ? blueDarkColor : blueDarkColor,
    boxShadow: state.isFocused ? 0 : 0,
    '&:hover': {
      borderColor: state.isFocused ? blueDarkColor : blueDarkColor
    }
  }),
  menu: (provided) => ({
    ...provided,
    borderRadius: 0,
    marginTop: 0,
    right: 0,
    zIndex: 9
  })
};

class TimeRangeFilter extends Component {
  constructor(props) {
    const {minDate, maxDate} = props;
    super(props);
    this.state = {
      isShowOptions: false,
      fromDate: null,
      toDate: null,
      defFromDate: minDate,
      defToDate: maxDate
    };

    this.optionsContainer = React.createRef();
  }

  componentDidMount() {
    document.addEventListener('mousedown', this.handleClickOutside);

    return () => {
      document.removeEventListener('mousedown', this.handleClickOutside);
    };
  }

  setShowOptions = value => this.setState({isShowOptions: value});

  handleCloseOptions = () => {
    this.setShowOptions(false);
  };

  handleClickOutside = (event) => {
    if (this.optionsContainer.current && !this.optionsContainer.current.contains(event.target)) {
      this.handleCloseOptions();
    }
  };

  handelChange = (value) => {
    const {onChange} = this.props;
    const {fromDate, toDate} = this.state;
    const result = {...value};
    Object.keys(result).forEach((key) => (result[key] == null) && delete result[key]);
    if (fromDate && !Object.keys(value).includes('fromDate')) Object.assign(result, {fromDate});
    if (toDate && !Object.keys(value).includes('toDate')) Object.assign(result, {toDate});
    onChange(result);
    this.setState(value);
  };

  renderOptions = () => {
    const {filterName, minDate, maxDate} = this.props;
    const {fromDate, toDate, defFromDate, defToDate} = this.state;
    const currentToDate = toDate || defToDate;
    const currentFromDate = fromDate || defFromDate;
    return (
      <div className="options-container" ref={this.optionsContainer}>
        <div className="select-field" onClick={this.handleCloseOptions}>
          <span>{filterName}</span><span className="toggle-indicator"><img src={minus} alt="" /></span>
        </div>
        <div className="time-range-options">
          <div className="slider-range-container">
            <Range
              className="slider-range"
              min={minDate}
              max={maxDate}
              trackStyle={[{ backgroundColor: redColor }]}
              handle={(handleProps) => (
                <Handle {...handleProps} key={handleProps.index} dragging={handleProps.dragging.toString()}>
                  <div className={`time-range-handle handel-${handleProps.index}`}>{handleProps.value}</div>
                </Handle>
              )}
              handleStyle={[
                { backgroundColor: redColor, border: 'none', height: '12px', width: '12px', marginTop: '-4px' },
                { backgroundColor: redColor, border: 'none', height: '18px', width: '18px', marginTop: '-7px' }
              ]}
              value={[fromDate || defFromDate, toDate || defToDate]}
              onChange={(e) => this.setState({fromDate: e[0], toDate: e[1]})}
              onAfterChange={(e) => this.handelChange({fromDate: e[0], toDate: e[1]})}
              railStyle={{ backgroundColor: greyColor, maxHeight: '2px', marginTop: '1px' }}
              activeDotStyle={{border: 'none'}}
            />
            <div className="values-row">
              <span>{minDate}</span>
              <span>{maxDate}</span>
            </div>
          </div>
          <div className="filter-item">
            <div className="caption">From</div>
            <Select
              options={
                [...new Array(currentToDate - minDate + 1)].map((v, i) => (
                  {value: currentToDate - i, label: currentToDate - i}
                ))
              }
              styles={customStyles}
              isSearchable={false}
              value={{label: fromDate || defFromDate, value: fromDate || defFromDate}}
              onChange={(e) => this.handelChange({fromDate: e.value})}
              components={{IndicatorSeparator: () => null}}
            />
          </div>
          <div className="filter-item">
            <div className="caption">To</div>
            <Select
              options={
                [...new Array(maxDate - currentFromDate + 1)].map((_, i) => (
                  {value: currentFromDate + i, label: currentFromDate + i})).reverse()
              }
              styles={customStyles}
              isSearchable={false}
              value={{label: toDate || defToDate, value: toDate || defToDate}}
              onChange={(e) => this.handelChange({toDate: e.value})}
              components={{IndicatorSeparator: () => null}}
            />
          </div>
        </div>
      </div>
    );
  };

  render() {
    const {isShowOptions, fromDate, toDate} = this.state;
    const {filterName} = this.props;
    let selectedCount = 0;
    if (fromDate) selectedCount += 1;
    if (toDate) selectedCount += 1;

    return (
      <Fragment>
        <div className="filter-container">
          <div className="control-field" onClick={() => this.setShowOptions(true)}>
            <div className="select-field">
              <span>{filterName}</span><span className="toggle-indicator"><img src={plus} alt="" /></span>
            </div>
            {selectedCount !== 0 && <div className="selected-count">{selectedCount} selected</div>}
          </div>
          { isShowOptions && this.renderOptions()}
        </div>
      </Fragment>
    );
  }
}

TimeRangeFilter.defaultProps = {
  onChange: () => {},
  filterName: 'Time range',
  minDate: 1990,
  maxDate: new Date().getUTCFullYear()
};

TimeRangeFilter.propTypes = {
  filterName: PropTypes.string,
  minDate: PropTypes.number,
  maxDate: PropTypes.number,
  onChange: PropTypes.func
};

export default TimeRangeFilter;
