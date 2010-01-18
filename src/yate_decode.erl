%% yate_decode: yate message decoding experimental erlang module.
%%
%% Copyright (C) 2009-2010 - Alca Società Cooperativa <info@alcacoop.it>
%%
%% Author: Luca Greco <luca.greco@alcacoop.it>
%%
%% This program is free software: you can redistribute it and/or modify
%% it under the terms of the GNU Lesser General Public License as published by
%% the Free Software Foundation, either version 3 of the License, or
%% (at your option) any later version.
%%
%% This program is distributed in the hope that it will be useful,
%% but WITHOUT ANY WARRANTY; without even the implied warranty of
%% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%% General Public License for more details.
%%
%% You should have received a copy of the GNU Lessel General Public License
%% along with this program.  If not, see <http://www.gnu.org/licenses/>.

%% @author Luca Greco <luca.greco@alcacoop.it>
%% @copyright 2009-2010 Alca Societa' Cooperativa

%% @doc 'yate_decode' is a simple yate module to decode yate_event erlang records from binary strings.
-module(yate_decode).

-compile(export_all).

%% @headerfile "../include/yate.hrl"
-include("yate.hrl").

-export([from_binary/1]).

%% @doc decode message type and call specialized attributes parsing functions
%% @spec from_binary(Raw::binary()) -> yate_event()
from_binary(Raw = <<"Error in: ", Msg/binary>>) when is_binary(Raw) ->
    #yate_event{ direction=incoming, type=error, attrs=[{msg, binary_to_list(Msg)}] };
from_binary(Raw = <<"%%<install:", Rest/binary>>) when is_binary(Raw) -> 
    #yate_event{ direction=answer, type=install, attrs=decode_install_answer_attributes(Rest) };
from_binary(Raw = <<"%%<uninstall:", Rest/binary>>) when is_binary(Raw) -> 
    #yate_event{ direction=answer, type=uninstall, attrs=decode_uninstall_answer_attributes(Rest) };
from_binary(Raw = <<"%%<watch:", Rest/binary>>) when is_binary(Raw) -> 
    #yate_event{ direction=answer, type=watch, attrs=decode_watch_answer_attributes(Rest) };
from_binary(Raw = <<"%%<unwatch:", Rest/binary>>) when is_binary(Raw) -> 
    #yate_event{ direction=answer, type=unwatch, attrs=decode_unwatch_answer_attributes(Rest) };
from_binary(Raw = <<"%%<setlocal:", Rest/binary>>) when is_binary(Raw) -> 
    #yate_event{ direction=answer, type=setlocal, attrs=decode_setlocal_answer_attributes(Rest) };
from_binary(Raw = <<"%%<message:", Rest/binary>>) when is_binary(Raw) -> 
    [ EventAttrs, MsgParams ] = decode_message_answer_attributes(Rest),
    #yate_event{ direction=answer, type=message, attrs=EventAttrs, params=MsgParams };
from_binary(Raw = <<"%%>message:", Rest/binary>>) when is_binary(Raw) ->
    [ EventAttrs, MsgParams ] = decode_message_incoming_attributes(Rest),
    #yate_event{ direction=incoming, type=message, attrs=EventAttrs, params=MsgParams };
from_binary(_Unknown) when is_binary(_Unknown) ->
    ?THROW_YATE_EXCEPTION(unknown_event, "Invalid Engine YATE Event", _Unknown);
from_binary(_Unknown) ->
    ?THROW_YATE_EXCEPTION(nonbinary_data, "Needs binary data", _Unknown).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% TODO: 'binary:split' seems to be more efficient way to split a binary string
%%%         http://www.erlang.org/eeps/eep-0009.html
%%%         http://stackoverflow.com/questions/428124/how-can-i-split-a-binary-in-erlang
%%% NOTE: private specialized attributes parsing functions
%%%       on error throws 
%%%  { invalid_data, { data, Data }, { where, File, Line } }
%%%       unimplemented features throws
%%%  { not_implemented, {data, Rest}, { where, ?FILE, ?LINE } }
%%%
%%% IMPLEMENTATION NOTES:
% throw({ not_implemented, {data, Rest}, { where, ?FILE, ?LINE } }).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

decode_install_answer_attributes(Rest) when is_binary(Rest) ->
    case string:tokens(binary_to_list(Rest), ":") of
	[ Priority, Name, Success ] -> [ { priority, Priority }, { name, Name }, { success, Success } ];
        _Any -> ?THROW_YATE_EXCEPTION(invalid_data, "Error parsing install answer attributes", _Any)
%% throw({ invalid_data, {data, _Any}, { where, ?FILE, ?LINE } })
    end.

decode_uninstall_answer_attributes(Rest) when is_binary(Rest) ->
    case string:tokens(binary_to_list(Rest), ":") of
	[ Name, Success ] -> [ { name, Name }, { success, Success } ];
        _Any -> ?THROW_YATE_EXCEPTION(invalid_data, "Error parsing uninstall answer attributes", _Any)
    end.

decode_watch_answer_attributes(Rest) when is_binary(Rest) ->
    case string:tokens(binary_to_list(Rest), ":") of
	[ Name, Success ] -> [ { name, Name }, { success, Success } ];
        _Any -> ?THROW_YATE_EXCEPTION(invalid_data, "Error parsing watch answer attributes", _Any)
    end.

decode_unwatch_answer_attributes(Rest) when is_binary(Rest) ->
    case string:tokens(binary_to_list(Rest), ":") of
	[ Name, Success ] -> [ { name, Name }, { success, Success } ];
        _Any -> ?THROW_YATE_EXCEPTION(invalid_data, "Error parsing unwatch answer attributes", _Any)
    end.

decode_setlocal_answer_attributes(Rest) when is_binary(Rest) ->
    case string:tokens(binary_to_list(Rest), ":") of
	[ Name, Value, Success ] -> [ { name, Name }, { value, Value }, { success, Success } ];
        _Any -> ?THROW_YATE_EXCEPTION(invalid_data, "Error parsing setlocal answer attributes", _Any)
    end.

%%% %%<message:<id>:<processed>:[<name>]:<retvalue>[:<key>=<value>...]
%%% TODO: name is optional verify with a test
decode_message_answer_attributes(Rest) when is_binary(Rest) ->
    case string:tokens(binary_to_list(Rest), ":") of
	[ Id, Processed, Name, RetVal | RawMsgParams ] -> 
	    Attrs = [ { id, Id }, { processed, Processed }, { name, Name }, { retval, RetVal }],
	    MsgParams = decode_message_parameters(RawMsgParams),
	    [Attrs, MsgParams];
        _Any -> ?THROW_YATE_EXCEPTION(invalid_data, "Error parsing answer message attributes", _Any)
    end.

%%% %%>message:<id>:<time>:<name>:<retvalue>[:<key>=<value>...]
decode_message_incoming_attributes(Rest) when is_binary(Rest) ->
    case string:tokens(binary_to_list(Rest), ":") of
	[ Id, Time, Name, RetVal | RawMsgParams ] -> 
	    Attrs = [ { id, Id }, { time, Time }, { name, Name }, { retval, RetVal }],
	    MsgParams = decode_message_parameters(RawMsgParams),
	    [Attrs, MsgParams];
        _Any -> ?THROW_YATE_EXCEPTION(invalid_data, "Error parsing incoming message attributes", _Any)
    end.

decode_message_parameters([H|T] = RawMsgParams) when is_list(RawMsgParams) ->
    MsgParam = case string:tokens(H, "=") of
		   [Key, Value] -> { list_to_atom(Key), Value };
		   _Any -> ?THROW_YATE_EXCEPTION(invalid_data, "Error parsing message parameters", _Any)
	       end,
    [MsgParam | decode_message_parameters(T)];
decode_message_parameters([]) ->
    [].

