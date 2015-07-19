<%--

    Copyright 2013 Netflix, Inc.

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.

--%>

<%@ page contentType="text/html;charset=UTF-8" %>
<head>
  <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
  <meta name="layout" content="main"/>
  <title>Aws Usage Detail</title>
</head>
<body>
<div class="" style="margin: auto; {{getBodyWidth('width: 1652px;')}} padding: 20px 30px"  ng-controller="detailCtrl">
  <table ng-show="!graphOnly()">
    <tr>
      <td>Start</td>
      <td>Show</td>
      <td>Project Search</td>
    </tr>
    <tr>
      <td>
        <input class="required" type="text" name="start" id="start" size="14"/>
        <div style="padding-top: 10px">End</div>
        <br><input class="required" type="text" name="end" id="end" size="14"/>
      </td>
      <td nowrap="">
        <input type="radio" ng-model="usage_cost" value="cost" id="radio_cost"> <label for="radio_cost" style="cursor: pointer">Cost</label>&nbsp;&nbsp;
        <input type="radio" ng-model="usage_cost" value="usage" id="radio_usage"> <label for="radio_usage" style="cursor: pointer">Usage</label>
        <div style="padding-top: 10px">Group by
          <select ng-model="groupBy" ng-options="a.name for a in groupBys"></select>
        </div>
        <div style="padding-top: 5px">Aggregate
          <select ng-model="consolidate">
            <option>hourly</option>
            <option>daily</option>
            <option>weekly</option>
            <option>monthly</option>
          </select>
        </div>
        <div style="padding-top: 5px">Plot type
          <select ng-model="plotType">
            <option>area</option>
            <option>column</option>
          </select>
        </div>
        <div style="padding-top: 5px" ng-show="throughput_metricname">
          <input type="checkbox" ng-model="showsps" id="showsps">
          <label for="showsps">Show {{throughput_metricname}}</label>
        </div>
        <div style="padding-top: 5px" ng-show="throughput_metricname">
          <input type="checkbox" ng-model="factorsps" id="factorsps">
          <label for="factorsps">Factor {{throughput_metricname}}</label>
        </div>
      </td>
      <td>
        <input class="required" type="text" name="project" id="project" size="100" ng-model="project" ng-keyup="if(event.keyCode) === 13 {updateUrl(); getData();}"/>
        <select ng-model="project">
          <option value="ALFRESCO">ALFRESCO</option>
          <option value="AWSEB">AWSEB</option>
          <option value="BASE">BASE</option>
          <option value="BO,BUSINESSOBJECT">BO,BUSINESSOBJECT</option>
          <option value="CATCHER">CATCHER</option>
          <option value="CLOUDFRONT">CLOUDFRONT</option>
          <option value="CLOUDWATCH">CLOUDWATCH</option>
          <option value="CONNECT">CONNECT</option>
          <option value="CONTENT">CONTENT</option>
          <option value="CORPSITES">CORPSITES</option>
          <option value="DEVOPS">DEVOPS</option>
          <option value="EBS">EBS</option>
          <option value="EC2">EC2</option>
          <option value="ECOMMERCE,SITESMART">ECOMMERCE,SITESMART</option>
          <option value="EIP">EIP</option>
          <option value="ELASTICACHE">ELASTICACHE</option>
          <option value="EMS">EMS</option>
          <option value="ETS">ETS</option>
          <option value="FINDABILITY">FINDABILITY</option>
          <option value="GLACIER">GLACIER</option>
          <option value="MARSHALL">MARSHALL</option>
          <option value="PITCHER">PITCHER</option>
          <option value="RDS">RDS</option>
          <option value="ROUTE53">ROUTE53</option>
          <option value="S3">S3</option>
          <option value="SALES-TOOLS">SALES-TOOLS</option>
          <option value="SAPI">SAPI</option>
          <option value="SAS">SAS</option>
          <option value="SDFCC,CUSTOMERCENTRE">SDFCC,CUSTOMERCENTRE</option>
          <option value="SDFCONTENT">SDFCONTENT</option>
          <option value="SDFORP">SDFORP</option>
          <option value="SHARED">SHARED</option>
          <option value="SPLUNK">SPLUNK</option>
          <option value="SSAPI">SSAPI</option>
          <option value="STORAGE">STORAGE</option>
          <option value="VCAC">VCAC</option>
          <option value="WP">WP</option>
          <option value="YELLOW">YELLOW</option>
          <option value="YOUTUBE">YOUTUBE</option>
        </select>
      </td>
  </table>

  <div class="buttons" ng-show="!graphOnly()">
    <img src="${resource(dir: '/')}images/spinner.gif" ng-show="loading">
    <a href="javascript:void(0)" class="monitor" style="background-image: url(${resource(dir: '/')}images/tango/16/apps/utilities-system-monitor.png)"
       ng-click="updateUrl(); getData()" ng-show="!loading"
       ng-disabled="selected_accounts.length == 0 || selected_regions.length == 0 || selected_products.length == 0 || showResourceGroups && selected_resourceGroups.length == 0 || selected_operations.length == 0 || selected_usageTypes.length == 0">Submit</a>
    <a href="javascript:void(0)" style="background-image: url(${resource(dir: '/')}images/tango/16/actions/document-save.png)"
       ng-click="download()" ng-show="!loading"
       ng-disabled="selected_accounts.length == 0 || selected_regions.length == 0 || selected_products.length == 0 || showResourceGroups && selected_resourceGroups.length == 0 || selected_operations.length == 0 || selected_usageTypes.length == 0">Download</a>
  </div>

  <table style="width: 100%; margin-top: 20px">
    <tr>
      <td ng-show="!graphOnly()">

        <div class="list">
          <div>
            <a href="javascript:void(0)" class="legendControls" ng-click="showall()">SHOW ALL</a>
            <a href="javascript:void(0)" class="legendControls" ng-click="hideall()">HIDE ALL</a>
            <input ng-model="filter_legend" type="text" class="metaFilter" placeHolder="filter" style="float: right; margin-right: 0">
          </div>
          <table style="width: 100%;">
            <thead>
            <tr>
              <th ng-click="order(legends, 'name', false)"><div class="legendIcon" style="{{legend.iconStyle}}"></div>{{legendName}}</th>
              <th ng-click="order(legends, 'total', true)">Total</th>
            </tr>
            </thead>
            <tbody>
            <tr ng-repeat="legend in legends | filter:filter_legend" style="{{legend.style}}; cursor: pointer;" ng-click="clickitem(legend)" class="{{getTrClass($index)}}">
              <td style="word-wrap: break-word">
                <div class="legendIcon" style="{{legend.iconStyle}}"></div>
                {{legend.name}}
              </td>
              <td><span ng-show="legend_usage_cost == 'cost'">{{currencySign}} </span>{{legend.stats.total | number:2}}</td>
            </tr>
            </tbody>
          </table>
        </div>
      </td>
      <td style="width: 80%">
        <div id="highchart_container" style="width: 100%; height: 600px;">
        </div>
      </td>
    </tr>
  </table>

</div>
</body>
</html>