(* Ocsigen
 * http://www.ocsigen.org
 * Copyright (C) 2012 Vincent Balat, Benedikt Becker
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, with linking exception;
 * either version 2.1 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 *)


(** See {% <<a_api | module Eliom_content>> %} for complete module. *)

module Xml : sig
  include Xml_sigs.Iterable
    with type 'a wrap = 'a
     and type 'a list_wrap = 'a list
     and type event_handler = (Dom_html.event Js.t -> unit) Eliom_lib.client_value
     and type mouse_event_handler = (Dom_html.mouseEvent Js.t -> unit) Eliom_lib.client_value
     and type keyboard_event_handler = (Dom_html.keyboardEvent Js.t -> unit) Eliom_lib.client_value

  type -'a caml_event_handler constraint 'a = #Dom_html.event

  (**/**)

  val make_process_node : ?id:string -> elt -> elt
  val make_request_node : elt -> elt

  val uri_of_fun: (unit -> string) -> uri

  (* Building ref tree. *)
  type node_id
  val get_node_id : elt -> node_id
  val make_event_handler_table : elt -> Eliom_lib.RawXML.event_handler_table
  val make_client_attrib_table : elt -> Eliom_lib.RawXML.client_attrib_table

  class type biggest_event = object
    inherit Dom_html.event
    inherit Dom_html.mouseEvent
    inherit Dom_html.keyboardEvent
  end

  type internal_event_handler =
    | Raw of string
    | Caml of biggest_event caml_event_handler

  val internal_event_handler_attrib : aname -> internal_event_handler -> attrib
  val internal_event_handler_of_service :
    ( [ `A | `Form_get | `Form_post ]
      * (bool * string list) option
      * string option) option Eliom_lazy.request -> internal_event_handler

  val caml_event_handler : ((#Dom_html.event as 'a) Js.t -> unit) Eliom_lib.client_value -> 'a caml_event_handler

  type racontent =
    | RA of acontent
    | RAReact of acontent option React.signal
    | RACamlEventHandler of biggest_event caml_event_handler
    | RALazyStr of string Eliom_lazy.request
    | RALazyStrL of separator * string Eliom_lazy.request list
    | RAClient of string * attrib option * attrib Eliom_lib.Client_value_server_repr.t

  val racontent : attrib -> racontent

  val lazy_node : ?a:(attrib list) -> ename -> elt list Eliom_lazy.request -> elt

  (**/**)
  val wrap : elt -> 'a -> 'a Eliom_wrap.wrapped_value

end

module Svg : sig

  type 'a wrap = 'a
  type 'a list_wrap = 'a list
  type +'a elt
  type +'a attrib
  type uri = Xml.uri

  module F : sig

    module Raw : Svg_sigs.T with type Xml.uri = Xml.uri
                             and type Xml.event_handler = Xml.event_handler
                             and type Xml.mouse_event_handler = Xml.mouse_event_handler
                             and type Xml.keyboard_event_handler = Xml.keyboard_event_handler
                             and type Xml.attrib = Xml.attrib
                             and type Xml.elt = Xml.elt
			     and type +'a elt = 'a elt
                             and type 'a Xml.wrap = 'a
                             and type 'a wrap = 'a
                             and type 'a Xml.list_wrap = 'a list
                             and type 'a list_wrap = 'a list
                             and type +'a attrib = 'a attrib
		             and type uri = uri

    include module type of Raw

  end

  module D : sig

    module Raw : Svg_sigs.T with type Xml.uri = Xml.uri
                             and type Xml.event_handler = Xml.event_handler
                             and type Xml.mouse_event_handler = Xml.mouse_event_handler
                             and type Xml.keyboard_event_handler = Xml.keyboard_event_handler
                             and type Xml.attrib = Xml.attrib
                             and type Xml.elt = Xml.elt
			     and type +'a elt = 'a elt
                             and type 'a Xml.wrap = 'a
                             and type 'a wrap = 'a
                             and type 'a Xml.list_wrap = 'a list
                             and type 'a list_wrap = 'a list
                             and type +'a attrib = 'a attrib
		             and type uri = uri

    include module type of Raw

    val client_attrib : ?init:'a attrib -> 'a attrib Eliom_lib.client_value -> 'a attrib

  end

  module Id : sig

    type +'a id

    val new_elt_id: ?global:bool -> unit -> 'a id

    val create_named_elt: id:'a id -> 'a elt -> 'a elt

    val create_global_elt: 'a elt -> 'a elt
  end

  module Printer : Xml_sigs.Typed_simple_printer with type +'a elt := 'a F.elt
                                          and type doc := F.doc

end

module Html5 : sig

  (** See the Eliom manual for more information on {% <<a_manual
      chapter="clientserver-html" fragment="unique"| dom semantics vs. functional
      semantics>> %} for HTML5 tree manipulated by client/server
      application. *)

  type 'a wrap = 'a
  type 'a list_wrap = 'a list
  type +'a elt
  type +'a attrib
  type uri = Xml.uri

  module F : sig

    module Raw : Html5_sigs.T
                   with type Xml.uri = Xml.uri
                   and type Xml.event_handler = Xml.event_handler
                   and type Xml.mouse_event_handler = Xml.mouse_event_handler
                   and type Xml.keyboard_event_handler = Xml.keyboard_event_handler
                   and type Xml.attrib = Xml.attrib
                   and type Xml.elt = Xml.elt
                   and type 'a Xml.wrap = 'a
                   and type 'a Xml.list_wrap = 'a list
                   with module Svg := Svg.F.Raw
                   with type +'a elt = 'a elt
                    and type 'a wrap = 'a
                    and type 'a list_wrap = 'a list
                   and type +'a attrib = 'a attrib
                   and type uri = uri

    include module type of Raw

    (**/**)
    type ('a, 'b, 'c) lazy_star =
      ?a: (('a attrib) list) -> ('b elt) list Eliom_lazy.request -> 'c elt

    val lazy_form:
      ([< Html5_types.form_attrib ], [< Html5_types.form_content_fun ], [> Html5_types.form ]) lazy_star
  end

  module D : sig

    module Raw : Html5_sigs.T
                   with type Xml.uri = Xml.uri
                   and type Xml.event_handler = Xml.event_handler
                   and type Xml.mouse_event_handler = Xml.mouse_event_handler
                   and type Xml.keyboard_event_handler = Xml.keyboard_event_handler
                   and type Xml.attrib = Xml.attrib
                   and type Xml.elt = Xml.elt
                   and type 'a Xml.wrap = 'a
                   and type 'a Xml.list_wrap = 'a list
                   with module Svg := Svg.D.Raw
                   with type +'a elt = 'a elt
                    and type 'a wrap = 'a
                    and type 'a list_wrap = 'a list
                   and type +'a attrib = 'a attrib
                   and type uri = uri
    include module type of Raw

    val client_attrib : ?init:'a attrib -> 'a attrib Eliom_lib.client_value -> 'a attrib

    (**/**)
    type ('a, 'b, 'c) lazy_star =
      ?a: (('a attrib) list) -> ('b elt) list Eliom_lazy.request -> 'c elt

    val lazy_form:
      ([< Html5_types.form_attrib ], [< Html5_types.form_content_fun ], [> Html5_types.form ]) lazy_star

  end

  module Id : sig
    type +'a id

    val new_elt_id: ?global:bool -> unit -> 'a id

    val create_named_elt: id:'a id -> 'a elt -> 'a elt

    val create_global_elt: 'a elt -> 'a elt

    (**/**)
    val have_id: 'a id -> 'b elt -> bool
  end

  module Custom_data : sig

    type 'a t

    val create : name:string -> ?default:'a -> to_string:('a -> string) -> of_string:(string -> 'a) -> unit -> 'a t

    val create_json : name:string -> ?default:'a -> 'a Deriving_Json.t -> 'a t

    val attrib : 'a t -> 'a -> [> | `User_data ] attrib

  end

  module Printer : Xml_sigs.Typed_simple_printer with type +'a elt := 'a F.elt
                                          and type doc := F.doc

end
