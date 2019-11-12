import React from "react";
import PropTypes from "prop-types";
import SingleBubbleChart from './SingleBubbleChart';

const COMPANIES_SIZES = {
  small: 18,
  medium: 33,
  large: 45
};

const LEVELS_COLORS = [
  '#86A9F9',
  '#5587F7',
  '#2465F5',
  '#0A4BDC',
  '#083AAB',
  '#042b82'
];

const BubbleChart = (data) => {
  const dataLevels = data.levels;
  const companies = data.companies;

  const parsedData = Object.keys(dataLevels).map(sectorName => ({
    sector: sectorName,
    data: Object.values(dataLevels[sectorName])
  }))

  /** Parsed data has this format - 
  * [
  *   { sector: 'Sector1', data: [ [ {}, {}, {} ], [], [], [], [], [] ] },
  *   { sector: 'Sector2', data: [ [], [], [], [], [], [] ] },
  *   { sector: 'Sector3', data: [ [], [], [], [], [], [] ] },
  *   { sector: 'Sector4', data: [ [], [], [], [], [], [] ] },
  *   { sector: 'Sector5', data: [ [], [], [], [], [], [] ] },
  *   { sector: 'Sector6', data: [ [], [], [], [], [], [] ] },
  *   { sector: 'Sector7', data: [ [], [], [], [], [], [] ] },
  *   { sector: 'Sector8', data: [ [], [], [], [], [], [] ] }
  * ]
  */

  const levelsSignature = Object.keys(companies);

  return (
    <div className="bubble-chart__container" style={{ 'gridTemplateColumns': `repeat(${levelsSignature.length + 1}, 1fr)` }}>
      <div></div>
      {levelsSignature.map((el, i) => (
        <div key={`${el}-${i}-${Math.random()}`}>
          {`Level ${el}`}
        </div>
      ))}
      {parsedData.map(dataRow => createRow(dataRow.data, dataRow.sector))}
    </div>   
  );
}

const PackBubbleChart = (companiesBubbles, uniqueKey) => {
  const width = 80;
  const height = 38;

  return (
    <SingleBubbleChart 
      width={width}
      height={height}
      uniqueKey={uniqueKey}
      data={companiesBubbles.length && companiesBubbles}
    />
  )
}

const createRow = (dataRow, title) => { 
  return (
    <React.Fragment key={Math.random()}>
      <div>
        {title}
      </div>
      {dataRow.map((el, i) => {
        const companiesBubbles = el.map(company => ({
          value: COMPANIES_SIZES[company.size],
          tooltipContent: [company.name, `Level ${company.level}`],
          color: LEVELS_COLORS[i]
        }))

        const uniqueKey = `${title}-${el.length}-${i}`;

        return (
          <div className="bubble-chart__cell" key={uniqueKey}>
            {PackBubbleChart(companiesBubbles, uniqueKey)}
          </div>
        )
      })}
    </React.Fragment>
  )
}

BubbleChart.propTypes = {
  data: PropTypes.object
};
export default BubbleChart;