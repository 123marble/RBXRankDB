"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[556],{3905:(e,t,n)=>{n.d(t,{Zo:()=>p,kt:()=>s});var r=n(67294);function a(e,t,n){return t in e?Object.defineProperty(e,t,{value:n,enumerable:!0,configurable:!0,writable:!0}):e[t]=n,e}function l(e,t){var n=Object.keys(e);if(Object.getOwnPropertySymbols){var r=Object.getOwnPropertySymbols(e);t&&(r=r.filter((function(t){return Object.getOwnPropertyDescriptor(e,t).enumerable}))),n.push.apply(n,r)}return n}function o(e){for(var t=1;t<arguments.length;t++){var n=null!=arguments[t]?arguments[t]:{};t%2?l(Object(n),!0).forEach((function(t){a(e,t,n[t])})):Object.getOwnPropertyDescriptors?Object.defineProperties(e,Object.getOwnPropertyDescriptors(n)):l(Object(n)).forEach((function(t){Object.defineProperty(e,t,Object.getOwnPropertyDescriptor(n,t))}))}return e}function i(e,t){if(null==e)return{};var n,r,a=function(e,t){if(null==e)return{};var n,r,a={},l=Object.keys(e);for(r=0;r<l.length;r++)n=l[r],t.indexOf(n)>=0||(a[n]=e[n]);return a}(e,t);if(Object.getOwnPropertySymbols){var l=Object.getOwnPropertySymbols(e);for(r=0;r<l.length;r++)n=l[r],t.indexOf(n)>=0||Object.prototype.propertyIsEnumerable.call(e,n)&&(a[n]=e[n])}return a}var u=r.createContext({}),c=function(e){var t=r.useContext(u),n=t;return e&&(n="function"==typeof e?e(t):o(o({},t),e)),n},p=function(e){var t=c(e.components);return r.createElement(u.Provider,{value:t},e.children)},d="mdxType",m={inlineCode:"code",wrapper:function(e){var t=e.children;return r.createElement(r.Fragment,{},t)}},f=r.forwardRef((function(e,t){var n=e.components,a=e.mdxType,l=e.originalType,u=e.parentName,p=i(e,["components","mdxType","originalType","parentName"]),d=c(n),f=a,s=d["".concat(u,".").concat(f)]||d[f]||m[f]||l;return n?r.createElement(s,o(o({ref:t},p),{},{components:n})):r.createElement(s,o({ref:t},p))}));function s(e,t){var n=arguments,a=t&&t.mdxType;if("string"==typeof e||a){var l=n.length,o=new Array(l);o[0]=f;var i={};for(var u in t)hasOwnProperty.call(t,u)&&(i[u]=t[u]);i.originalType=e,i[d]="string"==typeof e?e:a,o[1]=i;for(var c=2;c<l;c++)o[c]=n[c];return r.createElement.apply(null,o)}return r.createElement.apply(null,n)}f.displayName="MDXCreateElement"},52157:(e,t,n)=>{n.r(t),n.d(t,{contentTitle:()=>o,default:()=>d,frontMatter:()=>l,metadata:()=>i,toc:()=>u});var r=n(87462),a=(n(67294),n(3905));const l={},o="CHANGELOG.md",i={type:"mdx",permalink:"/RBXRankDB/CHANGELOG",source:"@site/pages/CHANGELOG.md",title:"CHANGELOG.md",description:"0.0.5 (2024-09-25)",frontMatter:{}},u=[{value:"0.0.5 (2024-09-25)",id:"005-2024-09-25",level:2},{value:"0.0.4 (2024-09-25)",id:"004-2024-09-25",level:2},{value:"0.0.3 (2024-09-25)",id:"003-2024-09-25",level:2},{value:"0.0.2 (2024-09-24)",id:"002-2024-09-24",level:2}],c={toc:u},p="wrapper";function d(e){let{components:t,...n}=e;return(0,a.kt)(p,(0,r.Z)({},c,n,{components:t,mdxType:"MDXLayout"}),(0,a.kt)("h1",{id:"changelogmd"},"CHANGELOG.md"),(0,a.kt)("h2",{id:"005-2024-09-25"},"0.0.5 (2024-09-25)"),(0,a.kt)("ul",null,(0,a.kt)("li",{parentName:"ul"},"Bug fix for ",(0,a.kt)("inlineCode",{parentName:"li"},"rbxRankDB:getRankRange")," to return ranks greater than or equal to the specified rank instead of greater than.")),(0,a.kt)("h2",{id:"004-2024-09-25"},"0.0.4 (2024-09-25)"),(0,a.kt)("ul",null,(0,a.kt)("li",{parentName:"ul"},"Added ",(0,a.kt)("inlineCode",{parentName:"li"},"rbxRankDB:getRankRange")," method to get a range of elements from a list based on rank.")),(0,a.kt)("h2",{id:"003-2024-09-25"},"0.0.3 (2024-09-25)"),(0,a.kt)("ul",null,(0,a.kt)("li",{parentName:"ul"},"Added methods to update/retrieve multiple elements in one request. ",(0,a.kt)("inlineCode",{parentName:"li"},"rbxRankDB:updateMultiElements")," and ",(0,a.kt)("inlineCode",{parentName:"li"},"rbxRankDB:getMultiElements"))),(0,a.kt)("h2",{id:"002-2024-09-24"},"0.0.2 (2024-09-24)"),(0,a.kt)("ul",null,(0,a.kt)("li",{parentName:"ul"},"Initial release")))}d.isMDXComponent=!0}}]);