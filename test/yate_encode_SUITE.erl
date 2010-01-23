-module(yate_encode_SUITE).

-compile(export_all).

-include("yate.hrl").

all() ->
    [
     encode_nonbinary_data,
     encode_invalid_application_yate_event,
     string_encode,

     encode_connect_yate_event,
     encode_output_yate_event,
     encode_setlocal_yate_event,

     encode_install_yate_event,
     encode_uninstall_yate_event,

     encode_watch_yate_event,
     encode_unwatch_yate_event,

     encode_message_outgoing_yate_event,
     encode_message_answer_yate_event
    ].


encode_nonbinary_data(_Config) ->
    YateInvalidDataException = (catch yate_encode:to_binary(non_yate_event_data)),
    invalid_data = YateInvalidDataException#yate_exception.type.

encode_invalid_application_yate_event(_Config) ->
    { skip, "Test not yet implemented"}.

string_encode(_Config) ->
    
    { skip, "Test not yet implemented"}.

encode_output_yate_event(_Config) ->
    YateEvent = #yate_event{
      type=output,
      direction=outgoing,
      attrs=[{text, "test message"}]
     },
    <<"%%>output:test message">> = yate_encode:to_binary(YateEvent).

encode_connect_yate_event(_Config) ->
    YateEvent = #yate_event{
      type=connect,
      direction=outgoing,
      attrs=[{role, "global"}]
     },
    <<"%%>connect:global">> = yate_encode:to_binary(YateEvent),
    YateEvent2 = #yate_event{
      type=connect,
      direction=outgoing,
      attrs=[{role, "channel"}, {channel_id, "sip/1"}, {channel_type, "play"}] 
     },
    <<"%%>connect:channel:sip/1:play">> = yate_encode:to_binary(YateEvent2).

encode_install_yate_event(_Config) ->
    YateEvent = #yate_event{
      type=install,
      direction=outgoing,
      attrs=[{name, "call.route"}]
     },
    <<"%%>install::call.route">> = yate_encode:to_binary(YateEvent),
    YateEvent2 = #yate_event{
      type=install,
      direction=outgoing,
      attrs=[{name, "call.route"},{priority, "100"}]
     },
    <<"%%>install:100:call.route">> = yate_encode:to_binary(YateEvent2),
    YateEvent3 = #yate_event{
      type=install,
      direction=outgoing,
      attrs=[{name, "call.route"},{priority, "100"},{filters,[{"chan_id","sip/1"}]}]
     },
    <<"%%>install:100:call.route:chan_id:sip/1">> = yate_encode:to_binary(YateEvent3).

encode_uninstall_yate_event(_Config) ->
    YateEvent = #yate_event{
      type=uninstall,
      direction=outgoing,
      attrs=[{name, "call.route"}]
     },
    <<"%%>uninstall:call.route">> = yate_encode:to_binary(YateEvent).

encode_watch_yate_event(_Config) ->
    YateEvent = #yate_event{
      type=watch,
      direction=outgoing,
      attrs=[{name, "call.route"}]
     },
    <<"%%>watch:call.route">> = yate_encode:to_binary(YateEvent).

encode_unwatch_yate_event(_Config) ->
    YateEvent = #yate_event{
      type=unwatch,
      direction=outgoing,
      attrs=[{name, "call.route"}]
     },
    <<"%%>unwatch:call.route">> = yate_encode:to_binary(YateEvent).

encode_setlocal_yate_event(_Config) ->
    YateEvent = #yate_event{
      type=setlocal,
      direction=outgoing,
      attrs=[{name, "restart"},{value, "true"}]
     },
    <<"%%>setlocal:restart:true">> = yate_encode:to_binary(YateEvent).

encode_message_outgoing_yate_event(_Config) ->
    YateEvent = #yate_event{
      type=message,
      direction=outgoing,
      attrs=[{id, "generated_id_123"},{time, "12312312312"},{name, "call.route"},{retvalue, "retvalue"}],
      params=[{chan_id, "sip/1"}]
     },
    <<"%%>message:generated_id_123:12312312312:call.route:retvalue:chan_id=sip/1">> = yate_encode:to_binary(YateEvent),
    YateEventMissingRetValue = #yate_event{
      type=message,
      direction=outgoing,
      attrs=[{id, "generated_id_123"},{time, "12312312312"},{name, "call.route"}],
      params=[{chan_id, "sip/1"}]
     },
    <<"%%>message:generated_id_123:12312312312:call.route::chan_id=sip/1">> = yate_encode:to_binary(YateEventMissingRetValue).

encode_message_answer_yate_event(_Config) ->
    YateEvent = #yate_event{
      type=message,
      direction=answer,
      attrs=[{id, "generated_id_123"},{processed, "true"},{name, "call.route"},{retvalue, "retvalue"}],
      params=[{chan_id, "sip/1"}]
     },
    <<"%%<message:generated_id_123:true:call.route:retvalue:chan_id=sip/1">> = yate_encode:to_binary(YateEvent),
    YateEventMissingRetValue = #yate_event{
      type=message,
      direction=answer,
      attrs=[{id, "generated_id_123"},{processed, "true"},{name, "call.route"}],
      params=[{chan_id, "sip/1"}]
     },
    <<"%%<message:generated_id_123:true:call.route::chan_id=sip/1">> = yate_encode:to_binary(YateEventMissingRetValue),
    io:format("starting missing name"),
    YateEventMissingName = #yate_event{
      type=message,
      direction=answer,
      attrs=[{id, "generated_id_123"},{processed, "true"},{retvalue, "retvalue"}],
      params=[{chan_id, "sip/1"}]
     },
    <<"%%<message:generated_id_123:true::retvalue:chan_id=sip/1">> = yate_encode:to_binary(YateEventMissingName),
    YateEventIntegerParam = #yate_event{
      type=message,
      direction=answer,
      attrs=[{id, "generated_id_123"},{processed, "true"},{retvalue, "retvalue"}],
      params=[{chan_id, "sip/1"},{users, 2}]
     },
    <<"%%<message:generated_id_123:true::retvalue:chan_id=sip/1:users=2">> = yate_encode:to_binary(YateEventIntegerParam).




