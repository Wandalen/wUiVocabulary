( function _Vocabulary_s_()
{

'use strict';

if( typeof module !== 'undefined' )
{

  require( '../../../node_modules/Tools' );

  const _ = _global_.wTools;

  _.include( 'wLogger' );
  _.include( 'wVocabulary' );

}

//

var $ = typeof jQuery === 'undefined' ? null : jQuery;
const _ = _global_.wTools;
const Parent = null;
const Self = wGhiVocabulary;
function wGhiVocabulary( o )
{
  return _.workpiece.construct( Self, this, arguments );
}

Self.shortName = 'GhiVocabulary';

//

function init( o )
{
  var self = this;

  self[ Symbol.for( 'headEnabled' ) ] = self.Self.prototype.Composes.headEnabled;

  _.workpiece.initFields( self );
  Object.preventExtensions( self );

  if( o )
  self.copy( o );

  if( self.usingGui )
  if( !self.bodyDom )
  self.bodyDom = $( document.body );

  self.initVocabulary();

}

//

function initVocabulary()
{
  var self = this;

  if( self.usingGui )
  {

    self.headDom = $( self.headDom );
    self.headMenuDom = self.headDom.children( '.menu' );
    self.phrasesDom = $( self.phrasesDom );

    _.assert( self.headDom.length > 0, 'no headDom found' );
    _.assert( self.headMenuDom.length > 0, 'no headMenuDom found' );
    _.assert( self.phrasesDom.length > 0, 'no phrasesDom found' );

  }

  //

  self.actionsRegister( [] );
  /*self.updateHead();*/

  var subject = self.subject;
  self.subject = '';
  self.subjectSet( subject );

  // head

  if( self.usingGui )
  self.headDom
  .dropdown
  ({

    allowAdditions : self.usingAdditions,

    onHide : function()
    {

      self.headEnabled = self.headEnabled;

    },

    onChange : function( val, text, event )
    {

      var text = text || val;
      _.assert( _.strIs( text ) );

      self.subjectSet( text );

    },

  });

  /*_.dom.uiInitGeneric( self.headDom );*/

  self.headEnabled = self.headEnabled;
  self.headFocused = self.headFocused;

  //

  if( self.usingHeadIcon && self.usingGui )
  {

    self.headDom.find( '.search.icon' )
    .bind( _.eventName( 'click' ), function()
    {

      self.headFocused = 1;

    });

  }

}

//

function updateHead()
{
  var self = this;
  var viewOptions =
  {
    subject : self.subject,
    vocabulary : self.vocabulary,
  }

  if( !self.usingGui )
  return;

  var htmlHead = self.onViewVocabularyHead( viewOptions );
  self.headMenuDom.html( htmlHead );

}

//

function actionsRegister( phrases, o )
{
  var self = this;

  _.assert( arguments.length <= 2 );

  function onPhraseDescriptorFrom( action )
  {
    if( _.routineIs( action ) )
    action = action.action;

    if( _.strIs( action ) )
    {
      action = { phrase : action };
    }
    else if( _.mapIs( action ) )
    {
      _.map.assertHasOnly( action, phraseOptionsDefault );
    }
    else throw _.err( 'unexpected' );

    if( o )
    _.props.supplement( action, o );

    _.props.supplement( action, phraseOptionsDefault );

    return action;
  }

  if( _.object.isBasic( phrases ) )
  phrases = [ phrases ];

  var o = o || {};
  phrases = _.container.map_( null, phrases, function( e )
  {
    if( _.routineIs( e ) )
    e = e.action;
    if( _.strIs( e ) )
    return e;
    return _.props.supplement( {}, e, o );
  });

  var vocabulary = self.vocabulary = self.vocabulary || wVocabulary
  ({
    onPhraseDescriptorFrom,
    clausing : self.clausing,
  });

  vocabulary.phrasesAdd( phrases );

  self.updateHead();

  return self;
}

//

function actionGet( phrase )
{
  var self = this;
  var result = { args : [] };
  var splitted;

  if( _.arrayIs( phrase ) )
  {
    splitted = phrase.slice();
    phrase = phrase.join( ' ' );
  }
  else
  {
    splitted = _.strSplitNonPreserving({ src : phrase, quoting : 0 });
  }

  _.assert( _.strIs( phrase ) );

  do
  {

    /*
        if( self.clausing && self.usingClausingAtActionGet )
        result.action = self.virtualDescriptorMap[ phrase ];
    */

    if( !result.action )
    result.action = self.vocabulary.phraseMap[ phrase ];

    if( result.action )
    break;

    result.args.unshift( splitted[ splitted.length-1 ] );
    splitted.pop();
    phrase = splitted.join( ' ' );

  }
  while( phrase );

  return result;
}

//

function eventEachAction( event )
{
  var self = this;
  var result = [];

  _.assert( _.strIs( event.kind ) );

  for( var d = 0 ; d < self.vocabulary.descriptorArray.length ; d++ )
  {
    var descriptor = self.vocabulary.descriptorArray[ d ];
    event.action = descriptor;
    if( descriptor.enabled )
    if( descriptor[ event.kind ] )
    result[ d ] = descriptor[ event.kind ].call( descriptor.context || self.context, event );
  }

  return result;
}

//

function actionsForSubject( subject )
{
  var self = this;

  var result = self.vocabulary.withSubphrase( subject );
  // var result = self.vocabulary.subjectDescriptorForWithClause( subject, self.clausing );

  return result;
}

//

function phrasesGet( o )
{
  var self = this;
  var o = o || {};

  _.routine.options_( phrasesGet, o );

  var phraseArray = self.vocabulary.phraseArray.slice();

  if( o.wordDelimeter )
  {

    for( var p = 0 ; p < phraseArray.length ; p++ )
    phraseArray[ p ] = _.strReplaceAll( phraseArray[ p ], ' ', o.wordDelimeter );

  }

  return phraseArray;
}

phrasesGet.defaults =
{
  wordDelimeter : null,
}

//

function subjectSet( subject )
{
  var self = this;
  _.assert( _.strIs( subject ) || subject === null );

  var subjectWas = self.subject;
  var subject = subject ? _.strStrip( subject ) : '';

  if( self.usingAdjustCase )
  subject = subject.toLowerCase();

  if( subjectWas === subject && subject )
  return;

  self.handleSubjectBegin( subject ).finallyGive( function()
  {

    self.subject = subject;

    if( self.usingGui )
    {

      var dropdownSubject = self.headDom.dropdown( 'get text' );
      if( dropdownSubject !== subject )
      self.headDom.dropdown( 'set text', subject );

    }

    var phrases = self.actionsForSubject( self.subject );
    var viewOptions =
    {

      subject : self.subject,
      vocabulary : self.vocabulary,
      phrases,

    }

    if( self.usingGui )
    {

      var htmlPhrases = self.onViewVocabularyPhrases( viewOptions );
      self.phrasesDom.html( htmlPhrases );

      self.phrasesDom.find( '.item' )
      .bind( _.eventName( 'click' ), _.routineJoin( self, activate ) );

    }

    self.handleSubjectEnd();

  });

}

//

function handleSubjectBegin( newSubject )
{
  var self = this;
  var result;

  _.assert( arguments.length === 1 );

  var begin = self.eventGive
  ({
    kind : 'vocabularySubjectBegin',
    vocabulary : self,
    subject : newSubject,
    subjectWas : self.subjectWas,
  });

  if( begin.length > 1 )
  throw _.err( 'Vocabulary :', 'Expects single vocabularySubjectBegin event handler' );

  if( begin.length === 1 && _.consequenceIs( begin[ 0 ] ) )
  result = begin[ 0 ];
  else if( begin.length === 1 && begin[ 0 ] === false )
  result = new _.Consequence()
  else
  result = new _.Consequence().take( null );

  return result;
}
//

function handleSubjectEnd()
{
  var self = this;

  self.eventGive
  ({
    kind : 'vocabularySubjectEnd',
    vocabulary : self,
    subject : self.subject,
    subjectWas : self.subjectWas,
  });

  var subjectResult = self.eventEachAction
  ({
    kind : self.names.onSubject,
    vocabulary : self,
    subject : self.subject,
    subjectWas : self.subjectWas,
  });

  for( var d = 0 ; d < subjectResult.length ; d++ )
  {
    if( subjectResult[ d ] )
    {
      _.time.out( 1, self, self.activate, [ { action : self.vocabulary.descriptorArray[ d ] } ] );
      break;
    }
  }

  if( self.usingBody && self.usingGui )
  {
    self.bodyDom.attr( 'subject', self.subject );
    self.bodyDom.attr( 'subject-was', self.subjectWas );
  }

}

//

function activate( o )
{
  var self = this;

  if( _.strIs( o ) )
  o = { phrase : o };
  else if( _.dom.eventIs( o ) )
  o = { phrase : $( o.target ).attr( 'phrase' ) };
  else if( _.dom.is( o ) || _.dom.jqueryIs( o ) )
  o = { phrase : $( o ).attr( 'phrase' ) };
  else if( !_.mapIs( o ) )
  throw _.err( 'unexepected arguments' );

  _.assert( arguments.length === 1 );
  _.routine.options_( activate, o );

  if( !o.action )
  {
    var a = self.actionGet( o.phrase );
    o.action = a.action;
    o.args = a.args;
  }

  if( !o.action )
  if( self.vocabulary.clauseMap && self.clausing )
  if( self.vocabulary.clauseMap[ o.phrase ] )
  {
    self.subjectSet( o.phrase );
    return;
  }

  if( !o.action )
  {
    throw _.err( 'Action not found :', o.phrase );
    throw _.err( 'not tested' );
  }

  self.handleActivate( o.action );
}

activate.defaults =
{
  phrase : null,
  action : null,
  args : null,
}

//

function deactivate( o )
{
  var self = this;
  var o = o || {};

  _.assert( arguments.length <= 1 );
  _.routine.options_( deactivate, o );

  if( !self.activeAction )
  return;

  if( self.activeAction.onDeactivate )
  self.activeAction.onDeactivate.call( self.activeAction.context || self.context,
    {
      kind : names.onDeactivate,
      vocabulary : self,
      subject : self.subject,
      phrase : o.phrase,
      action : o.action,
      actionWas : self.activeAction,
    });

}

deactivate.defaults =
{
  phrase : null,
  action : null,
}

//

function handleActivate( action, args, argsMap )
{
  var self = this;
  var con;

  _.assert( arguments.length >= 1 && arguments.length <= 3 );
  _.assert( _.object.isBasic( action ) );
  _.assert( _.strIs( action.phrase ) );

  if( !action.enabled )
  return;

  if( self.activeAction )
  self.deactivate
  ({
    phrase,
    action,
  });

  var phrase = action.phrase;
  var e =
  {
    kind : names.onActivate,
    subject : self.subject,
    vocabulary : self,
    phrase,
    action,
    actionWas : self.activeAction,
    args,
    argsMap
  };

  self.handleActivateBegin( e );

  if( action.onActivate )
  {
    try
    {
      con = action.onActivate.call( action.context || self.context, e );
    }
    catch( _err )
    {
      var err = _.err( 'error executing onActive of', action.phrase, 'action\n', _err );
      _.errLog( err );
      con = new _.Consequence().error( err );
    }
  }
  else if( self.verbosity )
  console.log( 'no "activate" handler for action', phrase );

  con = _.Consequence.From( con );

  con.tap( function()
  {

    return self.handleActivateEnd( e );

  });

  return con;
}

//

function handleActivateBegin( e )
{
  var self = this;

  // logger.log( 'handleActivateBegin',e.action ? e.action.phrase : null );

  e.action.active = true;

  self.activeAction = e.action;

  if( self.usingGui )
  {
    var item = self.phrasesDom.find( '.item' + '[ phrase="' + e.phrase + '" ]' );
    item.addClass( 'active' );

    if( e.action.bodyClass )
    self.bodyDom.addClass( e.action.bodyClass );
  }

  self.eventGive
  ({
    kind : 'vocabularyActivateBegin',
    vocabulary : self,
    subject : self.subject,
    phrase : e.phrase,
    action : e.action,
    actionWas : e.actionWas,
  });

  self.eventEachAction
  ({
    kind : names.onActivateAction,
    vocabulary : self,
    subject : self.subject,
    phrase : e.phrase,
    action : e.action,
    actionWas : e.actionWas,
  });

}

//

function handleActivateEnd( e )
{
  var self = this;

  // logger.log( 'handleActivateEnd',e.action ? e.action.phrase : null );

  if( self.activeAction !== e.action )
  {
    throw _.err( 'action', '"'+e.action.phrase+'"', 'is not active to be deactivated', '\ncurrent active action :', '"'+self.activeAction.phrase+'"' );
  }

  self.activeAction = null;

  self.eventEachAction
  ({
    kind : names.onDeactivateAction,
    vocabulary : self,
    subject : self.subject,
    phrase : e.phrase,
    action : e.action,
    actionWas : e.actionWas,
  });

  self.eventGive
  ({
    kind : 'vocabularyActivateEnd',
    vocabulary : self,
    subject : self.subject,
    phrase : e.phrase,
    action : e.action,
    actionWas : e.actionWas,
  });

  e.action.active = false;

  if( self.usingGui )
  {

    if( e.action.bodyClass )
    self.bodyDom.removeClass( e.action.bodyClass );

    var item = self.phrasesDom.find( '.item' + '[ phrase="' + e.phrase + '" ]' );
    item.removeClass( 'active' );

    /*alert( _.str( 'action','"'+e.phrase+'"','has just done!' ) );*/
    console.log( `action, "${e.phrase}" has just done!` );

  }

}

//

function _headEnabledSet( src )
{
  var self = this;

  if( !self.headDom || _.strIs( self.headDom ) )
  return;

  var input = self.headDom.find( 'input' );

  self[ Symbol.for( 'headEnabled' ) ] = src;

  if( src )
  input.removeAttr( 'disabled' );
  else
  input.attr( 'disabled', '1' );

}

//

function _headEnabledGet( src )
{
  var self = this;

  if( !self.headDom || _.strIs( self.headDom ) )
  return;

  return self[ Symbol.for( 'headEnabled' ) ];
/*
  var input = self.headDom.find( 'input' );
  return !_.str( input.attr( 'disabled' ) );
*/
}

//

function _headFocusedSet( src )
{
  var self = this;

  if( !self.headDom || _.strIs( self.headDom ) )
  return;

  var input = self.headDom.find( 'input' );

  if( src )
  input.removeAttr( 'disabled' );

  if( src )
  input[ 0 ].focus();
  else
  input[ 0 ].blur();

}

//

function _headFocusedGet( src )
{
  var self = this;

  if( !self.headDom || _.strIs( self.headDom ) )
  return;

  var input = self.headDom.find( 'input' );

  return input === document.activeElement;
}

// --
// type
// --

var phraseOptionsDefault =
{

  enabled : true,
  active : false,
  override : false,

  phrase : null,
  example : null,
  clauseLimit : null,

  onActivate : null,
  onDeactivate : null,
  onActivateAction : null,
  onDeactivateAction : null,
  onSubject : null,

  context : null,
  bodyClass : null,
  hint : '',

}

var names =
{
  onActivate : _.nameUnfielded({ onActivate : 'onActivate' }).coded,
  onDeactivate : _.nameUnfielded({ onDeactivate : 'onDeactivate' }).coded,
  onActivateAction : _.nameUnfielded({ onActivateAction : 'onActivateAction' }).coded,
  onDeactivateAction : _.nameUnfielded({ onDeactivateAction : 'onDeactivateAction' }).coded,
  onSubject : _.nameUnfielded({ onSubject : 'onSubject' }).coded,
}

// --
// relations
// --

var Composes =
{

  virtualDescriptorMap : _.define.own({}),

  onViewVocabularyHead : function(){ throw _.err( 'not assigned' ); },
  onViewVocabularyPhrases : function(){ throw _.err( 'not assigned' ); },

  usingAdjustCase : 1,
  verbosity : 1,
  usingHeadIcon : 1,
  usingAdditions : 0,
  clausing : 1,
  usingClausingAtActionGet : 1,
  usingBody : 1,
  usingGui : 1,

  headEnabled : 1,
  headFocused : 0,

}

var Associates =
{

  headDom : '.vocabulary-head',
  phrasesDom : '.vocabulary-phrases',
  headMenuDom : null,
  bodyDom : null,

  /*phrasesArray : null,*/

  vocabulary : null,
  subject : null,
  context : null,

}

var Restricts =
{
  activeAction : null,
}

var Events =
{
  vocabularySubjectBegin : 'vocabularySubjectBegin',
  vocabularySubjectEnd : 'vocabularySubjectEnd',
  vocabularyActivateBegin : 'vocabularyActivateBegin',
  vocabularyActivateEnd : 'vocabularyActivateEnd',

  onActivate : 'onActivate',
  onDeactivate : 'onDeactivate',
  onActivateAction : 'onActivateAction',
  onDeactivateAction : 'onDeactivateAction',
  onSubject : 'onSubject',
}

var Statics =
{
  phraseOptionsDefault,
  names,
}

var Accessors =
{

  headEnabled : 'headEnabled',
  headFocused : 'headFocused',

}

// --
// proto
// --

const Proto =
{

  init,
  initVocabulary,
  updateHead,

  actionsRegister,
  registerActions : actionsRegister,

  actionGet,
  eventEachAction,

  actionsForSubject,
  phrasesGet,

  subjectSet,
  handleSubjectBegin,
  handleSubjectEnd,

  activate,
  deactivate,

  handleActivate,
  handleActivateBegin,
  handleActivateEnd,

  _headEnabledSet,
  _headEnabledGet,
  _headFocusedSet,
  _headFocusedGet,

  // var

  phraseOptionsDefault,
  names,

  // relations

  Composes,
  Associates,
  Restricts,
  Events,

}

_.classDeclare
({
  cls : Self,
  parent : Parent,
  extend : Proto,
});

_.Copyable.mixin( Self );
_.EventHandler.mixin( Self );

//

_.accessor.declare( Self.prototype, Accessors );

//

_.ghi = _.ghi || Object.create( null );
_global_[ Self.name ] = _.ghi[ Self.shortName ] = Self;
if( typeof module !== 'undefined' )
module[ 'exports' ] = Self;

})();
