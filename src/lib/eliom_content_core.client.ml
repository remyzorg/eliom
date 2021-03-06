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


(* This the core of [Eliom_content] without its dependencies to [Eliom_service],
   [Eliom_client] et al.  Its name is not [Eliom_content_base] because this would
   suggest the sharing between server and client. *)

open Eliom_lib

module Xml = struct
  include RawXML
  type 'a wrap = 'a
  type 'a list_wrap = 'a list
  type econtent =
    | Empty
    | Comment of string
    | EncodedPCDATA of string
    | PCDATA of string
    | Entity of string
    | Leaf of ename * attrib list
    | Node of ename * attrib list * elt list
  and node =
    | DomNode of Dom.node Js.t
    | TyXMLNode of econtent
    | ReactNode of elt React.signal
  and elt = {
    (* See Eliom_content.Html5.To_dom for the 'unwrap' function that convert
       the server's tree representation into the client one. *)
    mutable elt : node lazy_t;
    node_id : node_id;
  }

  let content e =
    match Lazy.force e.elt with
    | ReactNode _
    | DomNode _ -> assert false (* TODO *)
    | TyXMLNode elt -> elt
  let get_node e = Lazy.force e.elt
  let set_dom_node elt node = elt.elt <- Lazy.lazy_from_val (DomNode node)
  let get_node_id elt = elt.node_id

  let make ?(id = NoId) elt =
    { elt = Lazy.lazy_from_val (TyXMLNode elt); node_id = id; }
  let make_dom ?(id = NoId) node =
    { elt = Lazy.lazy_from_val (DomNode node); node_id = id; }
  let make_lazy ?(id = NoId) lazy_elt =
    let f () =
       let elt = Lazy.force lazy_elt in
       assert (elt.node_id = id);
       Lazy.force elt.elt
    in
    { node_id = id; elt = Lazy.lazy_from_fun f }
  let force_lazy { elt } = ignore (Lazy.force elt)

  let make_react ?(id = NoId) signal =
    {elt = Lazy.lazy_from_val (ReactNode signal); node_id = id; }

  let empty () = make Empty

  let comment c = make (Comment c)
  let pcdata d = make (PCDATA d)
  let encodedpcdata d = make (EncodedPCDATA d)
  let entity e = make (Entity e)

  let leaf ?(a = []) name =  make (Leaf (name, a))
  let node ?(a = []) name children = make (Node (name, a, children))
  let lazy_node ?a name children = node ?a name (Eliom_lazy.force children)

  type biggest_event_handler = biggest_event Js.t -> unit

  type event_handler = Dom_html.event Js.t -> unit
  type mouse_event_handler = Dom_html.mouseEvent Js.t -> unit
  type keyboard_event_handler = Dom_html.keyboardEvent Js.t -> unit

  let event_handler_attrib name (value : event_handler) =
    internal_event_handler_attrib name
      (Caml (CE_client_closure (value :> biggest_event_handler)))
  let mouse_event_handler_attrib name (value : mouse_event_handler) =
    internal_event_handler_attrib name
      (Caml (CE_client_closure (value :> biggest_event_handler)))
  let keyboard_event_handler_attrib name (value : keyboard_event_handler) =
    internal_event_handler_attrib name
      (Caml (CE_client_closure (value :> biggest_event_handler)))

  let end_re = Regexp.regexp_string "]]>"

  let make_node_name =
    let node_id_counter = ref 0 in
    (fun ?(global = true) () ->
      incr node_id_counter;
      (if global then "global_" else "")
      ^ "client_" ^ (string_of_int !node_id_counter))

  let make_process_node ?(id = make_node_name ~global:true ()) elt =
    { elt with node_id = ProcessId id }

  let make_request_node elt =
    { elt with
      node_id = RequestId (make_node_name ()) }

  let cdata s =
    let s' =
      "\n<![CDATA[\n" ^ Regexp.global_replace end_re s "" ^ "\n]]>\n" in
    encodedpcdata s'

  let cdata_script s =
    let s' =
      "\n//<![CDATA[\n" ^ Regexp.global_replace end_re s "" ^ "\n//]]>\n" in
    encodedpcdata s'

  let cdata_style s =
    let s' =
      "\n/* <![CDATA[ */\n" ^ Regexp.global_replace end_re s "" ^ "\n/* ]]> */\n" in
    encodedpcdata s'

  let set_classes node_id = function
    | Empty
    | Comment _
    | EncodedPCDATA _
    | PCDATA _
    | Entity _ as e -> e
    | Leaf (ename, attribs) ->
      Leaf (ename, filter_class_attribs node_id attribs)
    | Node (ename, attribs, sons) ->
      Node (ename, filter_class_attribs node_id attribs, sons)

  let set_classes_of_elt elt =
     match Lazy.force elt.elt with
      | DomNode _ -> failwith "Eliom_content_core.set_classes_of_elt"
      | ReactNode _ -> failwith "Eliom_content_core.set_classes_of_elt"
      | TyXMLNode econtent ->
          { elt with elt = Lazy.lazy_from_val (TyXMLNode (set_classes elt.node_id econtent)) }

  let string_of_node_id = function
    | NoId -> "NoId"
    | ProcessId s -> "ProcessId "^s
    | RequestId s -> "RequestId "^s

end

module Xml_wed =
struct
  type 'a wrap = 'a Tyxml_js.Xml_wrap.t
  type 'a list_wrap = 'a Tyxml_js.Xml_wrap.tlist
  type uri = Xml.uri
  let string_of_uri = Xml.string_of_uri
  let uri_of_string = Xml.uri_of_string
  type aname = Xml.aname
  type event_handler = Xml.event_handler
  type mouse_event_handler = Xml.mouse_event_handler
  type keyboard_event_handler = Xml.keyboard_event_handler
  type attrib = Xml.attrib

  let float_attrib name s : attrib =
    name, Xml.RAReact (React.S.map (fun f -> Some (Xml.AFloat f)) s)
  let int_attrib name s =
    name, Xml.RAReact (React.S.map (fun f -> Some (Xml.AInt f)) s)
  let string_attrib name s =
    name, Xml.RAReact (React.S.map (fun f -> Some (Xml.AStr f)) s)
  let space_sep_attrib name s =
    name, Xml.RAReact (React.S.map (fun f -> Some(Xml.AStrL (Xml.Space,f))) s)
  let comma_sep_attrib name s =
    name, Xml.RAReact (React.S.map (fun f -> Some (Xml.AStrL (Xml.Comma,f))) s)
  let event_handler_attrib = Xml.event_handler_attrib
  let mouse_event_handler_attrib = Xml.mouse_event_handler_attrib
  let keyboard_event_handler_attrib = Xml.keyboard_event_handler_attrib
  let uri_attrib name value =
    name, Xml.RAReact (React.S.map
                         (fun f -> Some (Xml.AStr (Eliom_lazy.force f))) value)
  let uris_attrib name value =
    name,
    Xml.RAReact (React.S.map
                   (fun f -> Some (Xml.AStrL (Xml.Space,Eliom_lazy.force f)))
                   value)

  type elt = Xml.elt
  type ename = Xml.ename

  let empty = Xml.empty
  let comment = Xml.comment
  let pcdata s = Xml.make_react (React.S.map Xml.pcdata s)
  let encodedpcdata s = Xml.make_react (React.S.map Xml.encodedpcdata s)
  let entity = Xml.entity
  let leaf = Xml.leaf
  let node ?a name l = Xml.make_react (React.S.map (fun l -> Xml.node ?a name l) l)
  let cdata = Xml.cdata
  let cdata_script = Xml.cdata_script
  let cdata_style = Xml.cdata_style
end



module Svg = struct

  module D = struct

    module Raw = Svg_f.Make(struct
        include Xml

        let make elt = make_request_node (make elt)
        let make_lazy elt = make_request_node (make (Lazy.force elt))

        let empty () = make Empty

        let comment c = make (Comment c)
        let pcdata d = make (PCDATA d)
        let encodedpcdata d = make (EncodedPCDATA d)
        let entity e = make (Entity e)

        let leaf ?(a = []) name =  make (Leaf (name, a))
        let node ?(a = []) name children = make (Node (name, a, children))
        let lazy_node ?(a = []) name children =
          make (Node (name, a, Eliom_lazy.force children))

      end)

    include Raw

  end

  module F = struct

    module Raw = Svg_f.Make(Xml)

    include Raw

  end

  module R = struct
    module Raw = Svg_f.MakeWrapped(Tyxml_js.Xml_wrap)(Xml_wed)
    include Raw

  end

  type +'a elt = 'a F.elt
  type 'a wrap = 'a F.wrap
  type 'a list_wrap = 'a F.list_wrap
  type +'a attrib = 'a F.attrib
  type uri = F.uri

  module Id = struct
    type 'a id = string (* FIXME invariant type parameter ? *)
    let new_elt_id: ?global:bool -> unit -> 'a id = Xml.make_node_name
    let create_named_elt ~(id : 'a id) elt =
      D.tot (Xml.make_process_node ~id (D.toelt elt))
    let create_global_elt elt =
      D.tot (Xml.make_process_node (D.toelt elt))
    let string_of_id x = x
  end


  module Of_dom = struct
    let rebuild_xml (node: 'a Js.t) : 'a F.elt =
      Xml.make_dom (node :> Dom.node Js.t)
    let of_element : Dom_html.element Js.t -> 'a elt = rebuild_xml
  end


end

module Html5 = struct

  module D = struct
    module Xml' = struct
      include Xml

      let make elt = make_request_node (make elt)
      let make_lazy elt = make_request_node (make (Lazy.force elt))

      let empty () = make Empty

      let comment c = make (Comment c)
      let pcdata d = make (PCDATA d)
      let encodedpcdata d = make (EncodedPCDATA d)
      let entity e = make (Entity e)

      let leaf ?(a = []) name =  make (Leaf (name, a))
      let node ?(a = []) name children = make (Node (name, a, children))
      let lazy_node ?(a = []) name children =
        make (Node (name, a, Eliom_lazy.force children))
    end
    module Raw = Html5_f.Make(Xml')(Svg.D.Raw)

    include Raw

    type ('a, 'b, 'c) lazy_star =
        ?a: (('a attrib) list) -> ('b elt) list Eliom_lazy.request -> 'c elt

    let lazy_form ?(a = []) elts =
      tot (Xml'.lazy_node ~a:(to_xmlattribs a) "form"
	     (Eliom_lazy.from_fun
	        (fun () -> toeltl (Eliom_lazy.force elts))))

  end



  module R = struct

    let node s = Xml.make_react s

    module Raw = Html5_f.MakeWrapped(Tyxml_js.Xml_wrap)(Xml_wed)(Svg.R)
    include Raw
  end

  module F = struct

    module Xml' = Xml
    module Raw = Html5_f.Make(Xml')(Svg.F.Raw)
    include Raw

    type ('a, 'b, 'c) lazy_star =
        ?a: (('a attrib) list) -> ('b elt) list Eliom_lazy.request -> 'c elt

    let lazy_form ?(a = []) elts =
      tot (Xml'.lazy_node ~a:(to_xmlattribs a) "form"
	     (Eliom_lazy.from_fun
	        (fun () -> toeltl (Eliom_lazy.force elts))))

  end

  type +'a elt = 'a F.elt
  type 'a wrap = 'a F.wrap
  type 'a list_wrap = 'a F.list_wrap
  type +'a attrib = 'a F.attrib
  type uri = F.uri

  module Id = struct
    type 'a id = string (* FIXME invariant type parameter ? *)
    let new_elt_id: ?global:bool -> unit -> 'a id = Xml.make_node_name
    let new_global_elt_id () = new_elt_id ()
    let create_named_elt ~(id : 'a id) elt =
      D.tot (Xml.make_process_node ~id (D.toelt elt))
    let create_global_elt elt =
      D.tot (Xml.make_process_node (D.toelt elt))

    let string_of_id x = x
  end

  module Custom_data = struct

    type 'a t = {
      name : string;
      to_string : 'a -> string;
      of_string : string -> 'a;
      default : 'a option;
    }

    let create ~name ?default ~to_string ~of_string () =
      { name ; of_string ; to_string; default }

    let create_json ~name ?default typ =
      { name ; of_string = of_json ~typ ; to_string = to_json ~typ; default }

    let attrib custom_data value =
      F.a_user_data
        custom_data.name
        (custom_data.to_string value)

    let attribute_name name =
      "data-"^name

    let get_dom (element : Dom_html.element Js.t) custom_data =
      Js.Opt.case
        (element##getAttribute(Js.string (attribute_name custom_data.name)))
        (fun () ->
           match custom_data.default with
             | Some value -> value
             | None -> raise Not_found)
        (fun str -> custom_data.of_string (Js.to_string str))

    let set_dom element custom_data value =
      element##setAttribute(Js.string (attribute_name custom_data.name),
                            Js.string (custom_data.to_string value))

  end

  module Of_dom = Tyxml_cast.MakeOf(struct
      type 'a elt = 'a F.elt
      let elt (node: 'a Js.t) : 'a elt = Xml.make_dom (node :> Dom.node Js.t)
    end)

  let set_classes_of_elt elt = F.tot (Xml.set_classes_of_elt (F.toelt elt))

end
