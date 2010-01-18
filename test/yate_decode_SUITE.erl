-module(yate_decode_SUITE).

-compile(export_all).

-include("yate.hrl").

all() ->
    [
     decode_nonbinary_data,
     decode_unknown_events,

     decode_yate_errorin_incoming_event,

     decode_yate_install_answer_event,
     decode_invalid_yate_install_answer_event,

     decode_yate_uninstall_answer_event,
     decode_invalid_yate_uninstall_answer_event,

     decode_yate_watch_answer_event,
     decode_invalid_watch_answer_event,

     decode_yate_unwatch_answer_event,
     decode_invalid_unwatch_answer_event,

     decode_yate_setlocal_answer_event,
     decode_invalid_setlocal_answer_event,

     decode_yate_message_answer_event,
     decode_invalid_message_answer_event

    ].


decode_nonbinary_data(_Config) ->
    YateNonBinaryDataException = (catch yate_decode:from_binary(non_binary_data)),
    nonbinary_data = YateNonBinaryDataException#yate_exception.type.

decode_unknown_events(_Config) ->
    %%% NOTE: invalid direction of install message (incoming instead of answer or outgoing)
    YateUnknownEventException = (catch yate_decode:from_binary(<<"%%>install:100:call.route:true">>)),
    unknown_event = YateUnknownEventException#yate_exception.type.

decode_yate_errorin_incoming_event(_Config) ->
    ExpectedValue = #yate_event{
      direction=incoming,
      type=error,
      attrs=[{msg,"Test YATE error event decoding"}]
     },
    ExpectedValue = yate_decode:from_binary(<<"Error in: Test YATE error event decoding">>).

decode_yate_install_answer_event(_Config) ->
    ExpectedValue = #yate_event{
      direction=answer,
      type=install,
      attrs=[{priority, "100"},{name, "call.route"},{success, "true"}]
     },
    ExpectedValue = yate_decode:from_binary(<<"%%<install:100:call.route:true">>).

decode_invalid_yate_install_answer_event(_Config) ->
    %%% NOTE: missing priority 
    YateInvalidDataException = (catch yate_decode:from_binary(<<"%%<install:call.route:true">>)),
    invalid_data = YateInvalidDataException#yate_exception.type.

decode_yate_uninstall_answer_event(_Config) ->
    ExpectedValue = #yate_event{
      direction=answer,
      type=uninstall,
      attrs=[{name, "call.route"},{success, "true"}]
     },
    ExpectedValue = yate_decode:from_binary(<<"%%<uninstall:call.route:true">>).

decode_invalid_yate_uninstall_answer_event(_Config) ->
    %%% NOTE: missing success value
    YateInvalidDataException = (catch yate_decode:from_binary(<<"%%<uninstall:call.route">>)),
    invalid_data = YateInvalidDataException#yate_exception.type.

decode_yate_watch_answer_event(_Config) ->
    ExpectedValue = #yate_event{
      direction=answer,
      type=watch,
      attrs=[{name, "call.route"},{success, "true"}]
     },
    ExpectedValue = yate_decode:from_binary(<<"%%<watch:call.route:true">>).

decode_invalid_watch_answer_event(_Config) ->
    %%% NOTE: missing success value 
    YateInvalidDataException = (catch yate_decode:from_binary(<<"%%<watch:call.route">>)),
    invalid_data = YateInvalidDataException#yate_exception.type.

decode_yate_unwatch_answer_event(_Config) ->
    ExpectedValue = #yate_event{
      direction=answer,
      type=unwatch,
      attrs=[{name, "call.route"},{success, "true"}]
     },
    ExpectedValue = yate_decode:from_binary(<<"%%<unwatch:call.route:true">>).

decode_invalid_unwatch_answer_event(_Config) ->
    %%% NOTE: missing success value 
    YateInvalidDataException = (catch yate_decode:from_binary(<<"%%<unwatch:call.route">>)),
    invalid_data = YateInvalidDataException#yate_exception.type.

decode_yate_setlocal_answer_event(_Config) ->
    ExpectedValue = #yate_event{
      direction=answer,
      type=setlocal,
      attrs=[{name, "restart"},{value, "true"},{success, "true"}]
     },
    ExpectedValue = yate_decode:from_binary(<<"%%<setlocal:restart:true:true">>).

decode_invalid_setlocal_answer_event(_Config) ->
    %%% NOTE: missing setlocal and success value 
    YateInvalidDataException = (catch yate_decode:from_binary(<<"%%<setlocal:restart">>)),
    invalid_data = YateInvalidDataException#yate_exception.type.

decode_yate_message_answer_event(_Config) ->
    ExpectedValue = #yate_event{
      direction=answer,
      type=message,
      attrs=[{id, "messageid001"},{processed, "true"},{name, "call.route"},{retval, "true"}],
      params=[{chan_id, "sip/1"},{target_id, "sip/2"}]
     },
    ExpectedValue = yate_decode:from_binary(<<"%%<message:messageid001:true:call.route:true:chan_id=sip/1:target_id=sip/2">>).

decode_invalid_message_answer_event(_Config) ->
    %%% NOTE: missing setlocal a lot of data 
    YateInvalidDataException = (catch yate_decode:from_binary(<<"%%<message:call.route">>)),
    invalid_data = YateInvalidDataException#yate_exception.type.
