import React, { Component, Fragment } from 'react';
import PropTypes from 'prop-types';
import qs from 'qs';
import SearchFilter from '../../SearchFilter';

function getQueryFilters() {
  return qs.parse(window.location.search.slice(1));
}

class ClimateTargets extends Component {
  constructor(props) {
    super(props);
    const {
      climate_targets,
      count
    } = this.props;

    this.state = {
      climate_targets,
      count,
      activeGeoFilter: {},
      activeTagFilter: {}
    };

    this.geoFilter = React.createRef();
    this.tagsFilter = React.createRef();
  }

  filterList = (activeFilterName, filterParams) => {
    const {activeGeoFilter, activeTagFilter} = this.state;
    const filterList = {activeGeoFilter, activeTagFilter};
    const params = {...getQueryFilters};

    this.setState({[activeFilterName]: filterParams});
    filterList[activeFilterName] = filterParams;
    Object.assign(params, ...Object.values(filterList));
    const newQs = qs.stringify(params, { arrayFormat: 'brackets' });

    fetch(`/cclow/climate_targets.json?${newQs}`).then((response) => {
      response.json().then((data) => {
        if (response.ok) {
          this.setState({climate_targets: data.climate_targets, count: data.count});
        }
      });
    });
  };

  renderPageTitle() {
    const qFilters = getQueryFilters();

    const filterText = qFilters.q || (qFilters.recent && 'recent additions');

    if (filterText) {
      return (
        <h5 className="search-title">
          Search results: <strong>{filterText}</strong> in Climate Targets
        </h5>
      );
    }

    return (<h5 className="search-title">All Climate Targets</h5>);
  }

  renderTags = () => {
    const {activeGeoFilter, activeTagFilter} = this.state;
    const {geo_filter_options: geoFilterOptions, tags_filter_options: tagsFilterOptions} = this.props;
    if (Object.keys(activeGeoFilter).length === 0 && Object.keys(activeTagFilter).length === 0) return null;
    return (
      <div className="tags">
        {this.renderTagsGroup(activeGeoFilter, geoFilterOptions, 'geoFilter')}
        {this.renderTagsGroup(activeTagFilter, tagsFilterOptions, 'tagsFilter')}
      </div>
    );
  };

  renderTagsGroup = (activeTags, options, filterEl) => (
    <Fragment>
      {Object.keys(activeTags).map((keyBlock) => (
        activeTags[keyBlock].map((key, i) => (
          <span key={`tag_${keyBlock}_${i}`} className="tag">
            {options.filter(item => item.field_name === keyBlock)[0].options.filter(l => l.value === key)[0].label}
            <button type="button" onClick={() => this[filterEl].current.handleCheckItem(keyBlock, key)} className="delete" />
          </span>
        ))
      ))}
    </Fragment>
  );

  render() {
    const {climate_targets, count} = this.state;
    const {geo_filter_options: geoFilterOptions, tags_filter_options: tagsFilterOptions} = this.props;
    return (
      <Fragment>
        <div className="cclow-geography-page">
          <div className="container">
            {this.renderPageTitle()}
            <hr />
            <div className="columns">
              <div className="column is-one-quarter filter-column">
                <div className="search-by">Narrow this search by</div>
                <SearchFilter
                  ref={this.geoFilter}
                  filterName="Regions and countries"
                  params={geoFilterOptions}
                  onChange={(event) => this.filterList('activeGeoFilter', event)}
                />
                <SearchFilter
                  ref={this.tagsFilter}
                  filterName="Tags"
                  params={tagsFilterOptions}
                  onChange={(event) => this.filterList('activeTagFilter', event)}
                />
              </div>
              <main className="column is-three-quarters" data-controller="content-list">
                <div className="columns pre-content">
                  <span className="column is-half">Showing {count} results</span>
                  <a className="column is-half download-link" href="#">Download results (CSV in .zip)</a>
                </div>
                {this.renderTags()}
                <ul className="content-list">
                  {climate_targets.map((target, i) => (
                    <Fragment key={i}>
                      <li>
                        <h5 className="title" dangerouslySetInnerHTML={{__html: target.link}} />
                        <div className="meta">
                          {target.geography && (
                            <Fragment>
                              <div>
                                <img src={`../../../../assets/flags/${target.geography.iso}.svg`} alt="" />
                                {target.geography.name}
                              </div>
                            </Fragment>
                          )}
                          <div>{target.target_tags && target.target_tags.join(' | ')}</div>
                        </div>
                      </li>
                    </Fragment>
                  ))}
                </ul>
                <div className="column is-offset-5">
                  <button type="button" className="button is-primary load-more-btn">Load 10 more entries</button>
                </div>
              </main>
            </div>
          </div>
        </div>
      </Fragment>
    );
  }
}


ClimateTargets.defaultProps = {
  count: 0,
  geo_filter_options: [],
  tags_filter_options: []
};

ClimateTargets.propTypes = {
  climate_targets: PropTypes.array.isRequired,
  count: PropTypes.number,
  geo_filter_options: PropTypes.array,
  tags_filter_options: PropTypes.array
};

export default ClimateTargets;
