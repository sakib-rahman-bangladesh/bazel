# Copyright 2019 The Bazel Authors. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

""" A rule that mocks cc_toolchain configuration."""

load(
    "@bazel_tools//tools/cpp:cc_toolchain_config_lib.bzl",
    "action_config",
    "artifact_name_pattern",
    "env_entry",
    "env_set",
    "feature",
    "feature_set",
    "flag_group",
    "flag_set",
    "make_variable",
    "tool",
    "tool_path",
    "with_feature_set",
)
load("@bazel_tools//tools/build_defs/cc:action_names.bzl", "ACTION_NAMES")

_FEATURE_NAMES = struct(
    no_legacy_features = "no_legacy_features",
    do_not_split_linking_cmdline = "do_not_split_linking_cmdline",
    supports_dynamic_linker = "supports_dynamic_linker",
    supports_interface_shared_libraries = "supports_interface_shared_libraries",
    pic = "pic",
    parse_headers = "parse_headers",
    layering_check = "layering_check",
    header_modules = "header_modules",
    header_module_compile = "header_module_compile",
    header_module_codegen = "header_module_codegen",
    module_maps = "module_maps",
    use_header_modules = "use_header_modules",
    module_map_home_cwd = "module_map_home_cwd",
    env_feature = "env_feature",
    static_env_feature = "static_env_feature",
    host = "host",
    nonhost = "nonhost",
    user_compile_flags = "user_compile_flags",
    thin_lto = "thin_lto",
    thin_lto_linkstatic_tests_use_shared_nonlto_backends = "thin_lto_linkstatic_tests_use_shared_nonlto_backends",
    thin_lto_all_linkstatic_use_shared_nonlto_backends = "thin_lto_all_linkstatic_use_shared_nonlto_backends",
    enable_afdo_thinlto = "enable_afdo_thinlto",
    autofdo_implicit_thinlto = "autofdo_implicit_thinlto",
    enable_fdo_thinlto = "enable_fdo_thinlto",
    xbinaryfdo_implicit_thinlto = "xbinaryfdo_implicit_thinlto",
    enable_xbinaryfdo_thinlto = "enable_xbinaryfdo_thinlto",
    autofdo = "autofdo",
    is_cc_fake_binary = "is_cc_fake_binary",
    xbinaryfdo = "xbinaryfdo",
    fdo_optimize = "fdo_optimize",
    fdo_implicit_thinlto = "fdo_implicit_thinlto",
    fdo_instrument = "fdo_instrument",
    supports_pic = "supports_pic",
    copy_dynamic_libraries_to_binary = "copy_dynamic_libraries_to_binary",
    per_object_debug_info = "per_object_debug_info",
    supports_start_end_lib = "supports_start_end_lib",
    targets_windows = "targets_windows",
    static_link_cpp_runtimes = "static_link_cpp_runtimes",
    simple_compile_feature = "simple_compile_feature",
    simple_link_feature = "simple_link_feature",
    link_env = "link_env",
    dynamic_linking_mode = "dynamic_linking_mode",
    static_linking_mode = "static_linking_mode",
    compiler_param_file = "compiler_param_file",
    objcopy_embed_flags = "objcopy_embed_flags",
    ld_embed_flags = "ld_embed_flags",
    opt = "opt",
    fastbuild = "fastbuild",
    dbg = "dbg",
    fission_flags_for_lto_backend = "fission_flags_for_lto_backend",
    min_os_version_flag = "min_os_version_flag",
    include_directories = "include_directories",
    absolute_path_directories = "absolute_path_directories",
    from_package = "from_package",
    change_tool = "change_tool",
    module_map_without_extern_module = "module_map_without_extern_module",
    generate_submodules = "generate_submodules",
    foo = "foo_feature",
    library_search_directories = "library_search_directories",
    runtime_library_search_directories = "runtime_library_search_directories",
    uses_ifso_variables = "uses_ifso_variables",
    def_feature = "def",
    strip_debug_symbols = "strip_debug_symbols",
)

_no_legacy_features_feature = feature(name = _FEATURE_NAMES.no_legacy_features)

_do_not_split_linking_cmdline_feature = feature(name = _FEATURE_NAMES.do_not_split_linking_cmdline)

_supports_dynamic_linker_feature = feature(
    name = _FEATURE_NAMES.supports_dynamic_linker,
    enabled = True,
)

_supports_interface_shared_libraries_feature = feature(
    name = _FEATURE_NAMES.supports_interface_shared_libraries,
    enabled = True,
)

_pic_feature = feature(
    name = _FEATURE_NAMES.pic,
    enabled = True,
    flag_sets = [
        flag_set(
            actions = [
                ACTION_NAMES.assemble,
                ACTION_NAMES.preprocess_assemble,
                ACTION_NAMES.linkstamp_compile,
                ACTION_NAMES.c_compile,
                ACTION_NAMES.cpp_compile,
                ACTION_NAMES.cpp_module_codegen,
                ACTION_NAMES.cpp_module_compile,
            ],
            flag_groups = [
                flag_group(
                    expand_if_available = "pic",
                    flags = ["-fPIC"],
                ),
            ],
        ),
    ],
)

_parse_headers_feature = feature(
    name = _FEATURE_NAMES.parse_headers,
    flag_sets = [
        flag_set(
            actions = [ACTION_NAMES.cpp_header_parsing],
            flag_groups = [
                flag_group(
                    flags = ["<c++-header-parsing>"],
                ),
            ],
        ),
    ],
)

_layering_check_feature = feature(
    name = _FEATURE_NAMES.layering_check,
    flag_sets = [
        flag_set(
            actions = [
                ACTION_NAMES.c_compile,
                ACTION_NAMES.cpp_compile,
                ACTION_NAMES.cpp_header_parsing,
                ACTION_NAMES.cpp_module_compile,
            ],
            flag_groups = [
                flag_group(
                    iterate_over = "dependent_module_map_files",
                    flags = [
                        "dependent_module_map_file:%{dependent_module_map_files}",
                    ],
                ),
            ],
        ),
    ],
)

_simple_layering_check_feature = feature(
    name = _FEATURE_NAMES.layering_check,
    flag_sets = [
        flag_set(
            actions = [ACTION_NAMES.cpp_compile],
            flag_groups = [flag_group(flags = ["<flag>"])],
        ),
    ],
)

_header_modules_feature = feature(
    name = _FEATURE_NAMES.header_modules,
    implies = ["use_header_modules", "header_module_compile"],
)

_header_module_compile_feature = feature(
    name = _FEATURE_NAMES.header_module_compile,
    enabled = True,
    implies = ["module_maps"],
    flag_sets = [
        flag_set(
            actions = [ACTION_NAMES.cpp_module_compile],
            flag_groups = [
                flag_group(
                    flags = ["--woohoo_modules"],
                ),
            ],
        ),
        flag_set(
            actions = [ACTION_NAMES.cpp_module_codegen],
            flag_groups = [
                flag_group(
                    flags = ["--this_is_modules_codegen"],
                ),
            ],
        ),
    ],
)

_header_module_codegen_feature = feature(
    name = _FEATURE_NAMES.header_module_codegen,
    implies = ["header_modules"],
)

_module_maps_feature = feature(
    name = _FEATURE_NAMES.module_maps,
    enabled = True,
    flag_sets = [
        flag_set(
            actions = [
                ACTION_NAMES.c_compile,
                ACTION_NAMES.cpp_compile,
                ACTION_NAMES.cpp_header_parsing,
                ACTION_NAMES.cpp_module_compile,
            ],
            flag_groups = [
                flag_group(
                    flags = [
                        "module_name:%{module_name}",
                        "module_map_file:%{module_map_file}",
                    ],
                ),
            ],
        ),
    ],
)

_use_header_modules_feature = feature(
    name = _FEATURE_NAMES.use_header_modules,
    flag_sets = [
        flag_set(
            actions = [
                ACTION_NAMES.c_compile,
                ACTION_NAMES.cpp_compile,
                ACTION_NAMES.cpp_header_parsing,
                ACTION_NAMES.cpp_module_compile,
            ],
            flag_groups = [
                flag_group(
                    iterate_over = "module_files",
                    flags = ["module_file:%{module_files}"],
                ),
            ],
        ),
    ],
)

_header_modules_feature_configuration = [
    _header_modules_feature,
    _header_module_compile_feature,
    _header_module_codegen_feature,
    _module_maps_feature,
    _use_header_modules_feature,
]

_module_map_home_cwd_feature = feature(
    name = _FEATURE_NAMES.module_map_home_cwd,
    enabled = True,
    flag_sets = [
        flag_set(
            actions = [
                ACTION_NAMES.c_compile,
                ACTION_NAMES.cpp_compile,
                ACTION_NAMES.cpp_header_parsing,
                ACTION_NAMES.cpp_module_compile,
                ACTION_NAMES.cpp_header_parsing,
                ACTION_NAMES.preprocess_assemble,
            ],
            flag_groups = [
                flag_group(
                    flags = ["<flag>"],
                ),
            ],
        ),
    ],
)

_env_feature = feature(
    name = _FEATURE_NAMES.env_feature,
    implies = ["static_env_feature", "module_maps"],
)

_static_env_feature = feature(
    name = _FEATURE_NAMES.static_env_feature,
    env_sets = [
        env_set(
            actions = [
                ACTION_NAMES.c_compile,
                ACTION_NAMES.cpp_compile,
                ACTION_NAMES.cpp_header_parsing,
                ACTION_NAMES.cpp_module_compile,
            ],
            env_entries = [
                env_entry(
                    key = "cat",
                    value = "meow",
                ),
            ],
        ),
    ],
)

_module_maps_env_var_feature = feature(
    name = _FEATURE_NAMES.module_maps,
    enabled = True,
    env_sets = [
        env_set(
            actions = [
                ACTION_NAMES.c_compile,
                ACTION_NAMES.cpp_compile,
                ACTION_NAMES.cpp_header_parsing,
                ACTION_NAMES.cpp_module_compile,
            ],
            env_entries = [
                env_entry(
                    key = "module",
                    value = "module_name:%{module_name}",
                ),
            ],
        ),
    ],
)

_env_var_feature_configuration = [
    _env_feature,
    _static_env_feature,
    _module_maps_env_var_feature,
]

_host_feature = feature(
    name = _FEATURE_NAMES.host,
    flag_sets = [
        flag_set(
            actions = [ACTION_NAMES.c_compile, ACTION_NAMES.cpp_compile],
            flag_groups = [flag_group(flags = ["-host"])],
        ),
    ],
)

_nonhost_feature = feature(
    name = _FEATURE_NAMES.nonhost,
    flag_sets = [
        flag_set(
            actions = [ACTION_NAMES.c_compile, ACTION_NAMES.cpp_compile],
            flag_groups = [flag_group(flags = ["-nonhost"])],
        ),
    ],
)

_host_and_nonhost_configuration = [
    _host_feature,
    _nonhost_feature,
]

_user_compile_flags_feature = feature(
    name = _FEATURE_NAMES.user_compile_flags,
    enabled = True,
    flag_sets = [
        flag_set(
            actions = [
                ACTION_NAMES.assemble,
                ACTION_NAMES.preprocess_assemble,
                ACTION_NAMES.linkstamp_compile,
                ACTION_NAMES.c_compile,
                ACTION_NAMES.cpp_compile,
                ACTION_NAMES.cpp_header_parsing,
                ACTION_NAMES.cpp_module_compile,
                ACTION_NAMES.cpp_module_codegen,
                ACTION_NAMES.lto_backend,
                ACTION_NAMES.clif_match,
            ],
            flag_groups = [
                flag_group(
                    flags = ["%{user_compile_flags}"],
                    iterate_over = "user_compile_flags",
                    expand_if_available = "user_compile_flags",
                ),
            ],
        ),
    ],
)

_thin_lto_feature = feature(
    name = _FEATURE_NAMES.thin_lto,
    flag_sets = [
        flag_set(
            actions = [
                ACTION_NAMES.cpp_link_executable,
                ACTION_NAMES.cpp_link_dynamic_library,
                ACTION_NAMES.cpp_link_nodeps_dynamic_library,
                ACTION_NAMES.cpp_link_static_library,
            ],
            flag_groups = [
                flag_group(
                    expand_if_available = "thinlto_param_file",
                    flags = ["thinlto_param_file=%{thinlto_param_file}"],
                ),
            ],
        ),
        flag_set(
            actions = [ACTION_NAMES.c_compile, ACTION_NAMES.cpp_compile],
            flag_groups = [
                flag_group(flags = ["-flto=thin"]),
                flag_group(
                    flags = ["lto_indexing_bitcode=%{lto_indexing_bitcode_file}"],
                    expand_if_available = "lto_indexing_bitcode_file",
                ),
            ],
        ),
        flag_set(
            actions = [ACTION_NAMES.lto_indexing],
            flag_groups = [
                flag_group(
                    flags = [
                        "param_file=%{thinlto_indexing_param_file}",
                        "prefix_replace=%{thinlto_prefix_replace}",
                    ],
                ),
                flag_group(
                    flags = ["object_suffix_replace=%{thinlto_object_suffix_replace}"],
                    expand_if_available = "thinlto_object_suffix_replace",
                ),
                flag_group(
                    flags = ["thinlto_merged_object_file=%{thinlto_merged_object_file}"],
                    expand_if_available = "thinlto_merged_object_file",
                ),
            ],
        ),
        flag_set(
            actions = [ACTION_NAMES.lto_backend],
            flag_groups = [
                flag_group(
                    flags = [
                        "thinlto_index=%{thinlto_index}",
                        "thinlto_output_object_file=%{thinlto_output_object_file}",
                        "thinlto_input_bitcode_file=%{thinlto_input_bitcode_file}",
                    ],
                ),
            ],
        ),
    ],
    requires = [feature_set(features = ["nonhost"])],
)

_thin_lto_linkstatic_tests_use_shared_nonlto_backends_feature = feature(
    name = _FEATURE_NAMES.thin_lto_linkstatic_tests_use_shared_nonlto_backends,
)

_thin_lto_all_linkstatic_use_shared_nonlto_backends_feature = feature(
    name = _FEATURE_NAMES.thin_lto_all_linkstatic_use_shared_nonlto_backends,
)

_enable_afdo_thinlto_feature = feature(
    name = _FEATURE_NAMES.enable_afdo_thinlto,
    requires = [feature_set(features = ["autofdo_implicit_thinlto"])],
    implies = ["thin_lto"],
)

_autofdo_implicit_thinlto_feature = feature(name = _FEATURE_NAMES.autofdo_implicit_thinlto)

_enable_fdo_thin_lto_feature = feature(
    name = _FEATURE_NAMES.enable_fdo_thinlto,
    requires = [feature_set(features = ["fdo_implicit_thinlto"])],
    implies = ["thin_lto"],
)

_fdo_implicit_thinlto_feature = feature(name = _FEATURE_NAMES.fdo_implicit_thinlto)

_enable_xbinaryfdo_thinlto_feature = feature(
    name = _FEATURE_NAMES.enable_xbinaryfdo_thinlto,
    requires = [feature_set(features = ["xbinaryfdo_implicit_thinlto"])],
    implies = ["thin_lto"],
)

_xbinaryfdo_implicit_thinlto_feature = feature(name = _FEATURE_NAMES.xbinaryfdo_implicit_thinlto)

_autofdo_feature = feature(
    name = _FEATURE_NAMES.autofdo,
    flag_sets = [
        flag_set(
            actions = [
                ACTION_NAMES.c_compile,
                ACTION_NAMES.cpp_compile,
                ACTION_NAMES.lto_backend,
            ],
            flag_groups = [
                flag_group(
                    flags = [
                        "-fauto-profile=%{fdo_profile_path}",
                        "-fprofile-correction",
                    ],
                    expand_if_available = "fdo_profile_path",
                ),
            ],
        ),
    ],
    provides = ["profile"],
)

_is_cc_fake_binary_feature = feature(name = _FEATURE_NAMES.is_cc_fake_binary)

_xbinaryfdo_feature = feature(
    name = _FEATURE_NAMES.xbinaryfdo,
    flag_sets = [
        flag_set(
            actions = [
                ACTION_NAMES.c_compile,
                ACTION_NAMES.cpp_compile,
                ACTION_NAMES.lto_backend,
            ],
            flag_groups = [
                flag_group(
                    flags = [
                        "-fauto-profile=%{fdo_profile_path}",
                        "-fprofile-correction",
                    ],
                ),
            ],
            with_features = [
                with_feature_set(not_features = ["is_cc_fake_binary"]),
            ],
        ),
    ],
    provides = ["profile"],
)

_fdo_optimize_feature = feature(
    name = _FEATURE_NAMES.fdo_optimize,
    flag_sets = [
        flag_set(
            actions = [ACTION_NAMES.c_compile, ACTION_NAMES.cpp_compile],
            flag_groups = [
                flag_group(
                    flags = [
                        "-fprofile-use=%{fdo_profile_path}",
                        "-Xclang-only=-Wno-profile-instr-unprofiled",
                        "-Xclang-only=-Wno-profile-instr-out-of-date",
                        "-Xclang-only=-Wno-backend-plugin",
                        "-fprofile-correction",
                    ],
                    expand_if_available = "fdo_profile_path",
                ),
            ],
        ),
    ],
    provides = ["profile"],
)

_fdo_instrument_feature = feature(
    name = _FEATURE_NAMES.fdo_instrument,
    flag_sets = [
        flag_set(
            actions = [
                ACTION_NAMES.c_compile,
                ACTION_NAMES.cpp_compile,
                ACTION_NAMES.cpp_link_dynamic_library,
                ACTION_NAMES.cpp_link_nodeps_dynamic_library,
                ACTION_NAMES.cpp_link_executable,
            ],
            flag_groups = [
                flag_group(
                    flags = ["fdo_instrument_option", "path=%{fdo_instrument_path}"],
                ),
            ],
        ),
    ],
    provides = ["profile"],
)

_per_object_debug_info_feature = feature(
    name = _FEATURE_NAMES.per_object_debug_info,
    enabled = True,
    flag_sets = [
        flag_set(
            actions = [
                ACTION_NAMES.c_compile,
                ACTION_NAMES.cpp_compile,
                ACTION_NAMES.assemble,
                ACTION_NAMES.preprocess_assemble,
                ACTION_NAMES.cpp_module_codegen,
                ACTION_NAMES.lto_backend,
            ],
            flag_groups = [
                flag_group(
                    flags = ["per_object_debug_info_option"],
                    expand_if_available = "per_object_debug_info_file",
                ),
            ],
        ),
    ],
)

_copy_dynamic_libraries_to_binary_feature = feature(
    name = _FEATURE_NAMES.copy_dynamic_libraries_to_binary,
)

_supports_start_end_lib_feature = feature(
    name = _FEATURE_NAMES.supports_start_end_lib,
    enabled = True,
)

_supports_pic_feature = feature(name = _FEATURE_NAMES.supports_pic, enabled = True)

_targets_windows_feature = feature(
    name = _FEATURE_NAMES.targets_windows,
    enabled = True,
    implies = ["copy_dynamic_libraries_to_binary"],
)

_compiler_param_file_feature = feature(
    name = _FEATURE_NAMES.compiler_param_file,
    enabled = True,
)

_static_link_cpp_runtimes_feature = feature(
    name = _FEATURE_NAMES.static_link_cpp_runtimes,
    enabled = True,
)

_simple_compile_feature = feature(
    name = _FEATURE_NAMES.simple_compile_feature,
    flag_sets = [
        flag_set(
            actions = [ACTION_NAMES.cpp_compile],
            flag_groups = [
                flag_group(flags = ["<flag>"]),
            ],
        ),
    ],
)

_simple_link_feature = feature(
    name = _FEATURE_NAMES.simple_link_feature,
    flag_sets = [
        flag_set(
            actions = [ACTION_NAMES.cpp_link_executable],
            flag_groups = [
                flag_group(flags = ["testlinkopt"]),
            ],
        ),
    ],
)

_link_env_feature = feature(
    name = _FEATURE_NAMES.link_env,
    env_sets = [
        env_set(
            actions = [
                ACTION_NAMES.cpp_link_static_library,
                ACTION_NAMES.cpp_link_dynamic_library,
                ACTION_NAMES.cpp_link_executable,
            ],
            env_entries = [
                env_entry(
                    key = "foo",
                    value = "bar",
                ),
            ],
        ),
    ],
)

_static_linking_mode_feature = feature(
    name = _FEATURE_NAMES.static_linking_mode,
    env_sets = [
        env_set(
            actions = [ACTION_NAMES.cpp_link_executable],
            env_entries = [
                env_entry(
                    key = "linking_mode",
                    value = "static",
                ),
            ],
        ),
    ],
)

_dynamic_linking_mode_feature = feature(
    name = _FEATURE_NAMES.dynamic_linking_mode,
    env_sets = [
        env_set(
            actions = [ACTION_NAMES.cpp_link_executable],
            env_entries = [
                env_entry(
                    key = "linking_mode",
                    value = "dynamic",
                ),
            ],
        ),
    ],
)

_objcopy_embed_flags_feature = feature(
    name = _FEATURE_NAMES.objcopy_embed_flags,
    enabled = True,
    flag_sets = [
        flag_set(
            actions = ["objcopy_embed_data"],
            flag_groups = [
                flag_group(flags = ["-objcopy-flag-1", "foo"]),
            ],
        ),
    ],
)

_ld_embed_flags_feature = feature(
    name = _FEATURE_NAMES.ld_embed_flags,
    enabled = True,
    flag_sets = [
        flag_set(
            actions = ["ld_embed_data"],
            flag_groups = [
                flag_group(flags = ["-ld-flag-1", "bar"]),
            ],
        ),
    ],
)

_dbg_compilation_feature = feature(
    name = _FEATURE_NAMES.dbg,
    flag_sets = [
        flag_set(
            actions = [ACTION_NAMES.cpp_compile],
            flag_groups = [
                flag_group(flags = ["-dbg"]),
            ],
        ),
    ],
)

_fastbuild_compilation_feature = feature(
    name = _FEATURE_NAMES.fastbuild,
    flag_sets = [
        flag_set(
            actions = [ACTION_NAMES.cpp_compile],
            flag_groups = [
                flag_group(flags = ["-fastbuild"]),
            ],
        ),
    ],
)

_opt_compilation_feature = feature(
    name = _FEATURE_NAMES.opt,
    flag_sets = [
        flag_set(
            actions = [ACTION_NAMES.cpp_compile],
            flag_groups = [
                flag_group(flags = ["-opt"]),
            ],
        ),
    ],
)

_compilation_mode_features = [
    _dbg_compilation_feature,
    _fastbuild_compilation_feature,
    _opt_compilation_feature,
]

_compile_header_modules_feature_configuration = [
    _supports_pic_feature,
    feature(name = "header_modules", implies = ["use_header_modules"]),
    _module_maps_feature,
    feature(name = "use_header_modules"),
]

_fission_flags_for_lto_backend_feature = feature(
    name = _FEATURE_NAMES.fission_flags_for_lto_backend,
    enabled = True,
    flag_sets = [
        flag_set(
            actions = [ACTION_NAMES.lto_backend],
            flag_groups = [
                flag_group(
                    expand_if_available = "is_using_fission",
                    flags = ["-<IS_USING_FISSION>"],
                ),
                flag_group(
                    expand_if_available = "per_object_debug_info_file",
                    flags = ["-<PER_OBJECT_DEBUG_INFO_FILE>"],
                ),
            ],
        ),
    ],
)

_min_os_version_flag_feature = feature(
    name = _FEATURE_NAMES.min_os_version_flag,
    flag_sets = [
        flag_set(
            actions = [ACTION_NAMES.cpp_compile],
            flag_groups = [
                flag_group(
                    expand_if_available = "min_os_version_flag",
                    flags = ["-DMIN_OS=%{minimum_os_version}"],
                ),
            ],
        ),
    ],
)

_include_directories_feature = feature(
    name = _FEATURE_NAMES.include_directories,
    enabled = True,
    flag_sets = [
        flag_set(
            actions = [ACTION_NAMES.cpp_compile],
            flag_groups = [
                flag_group(
                    flags = [
                        "-isysteminclude_1",
                        "-isystem",
                        "-include_2",
                        "-iquoteinclude_2",
                        "-Iinclude_3",
                    ],
                ),
            ],
        ),
    ],
)

_from_package_feature = feature(
    name = _FEATURE_NAMES.from_package,
    flag_sets = [
        flag_set(
            actions = [ACTION_NAMES.c_compile],
            flag_groups = [
                flag_group(flags = ["<flag>"]),
            ],
        ),
    ],
)

_absolute_path_directories_feature = feature(
    name = _FEATURE_NAMES.absolute_path_directories,
    enabled = True,
    flag_sets = [
        flag_set(
            actions = [ACTION_NAMES.cpp_compile],
            flag_groups = [
                flag_group(
                    flags = [
                        "-isystem",
                        "/some/absolute/path/subdir",
                    ],
                ),
            ],
        ),
    ],
)

_change_tool_feature = feature(
    name = _FEATURE_NAMES.change_tool,
)

_module_map_without_extern_module_feature = feature(
    name = _FEATURE_NAMES.module_map_without_extern_module,
)

_generate_submodules_feature = feature(
    name = _FEATURE_NAMES.generate_submodules,
)

_multiple_tools_action_config = action_config(
    action_name = ACTION_NAMES.cpp_compile,
    tools = [
        tool(
            path = "SPECIAL_TOOL",
            with_features = [
                with_feature_set(features = [_FEATURE_NAMES.change_tool]),
            ],
        ),
        tool(path = "DEFAULT_TOOL"),
    ],
)

_foo_feature = feature(
    name = _FEATURE_NAMES.foo,
)

_library_search_directories_feature = feature(
    name = _FEATURE_NAMES.library_search_directories,
    enabled = True,
    flag_sets = [
        flag_set(
            actions = [ACTION_NAMES.cpp_link_executable],
            flag_groups = [
                flag_group(
                    expand_if_available = "library_search_directories",
                    iterate_over = "library_search_directories",
                    flags = ["--library=%{library_search_directories}"],
                ),
            ],
        ),
    ],
)

_runtime_library_search_directories_feature = feature(
    name = _FEATURE_NAMES.runtime_library_search_directories,
    enabled = True,
    flag_sets = [
        flag_set(
            actions = [ACTION_NAMES.cpp_link_executable],
            flag_groups = [
                flag_group(
                    expand_if_available = "runtime_library_search_directories",
                    iterate_over = "runtime_library_search_directories",
                    flags = ["--runtime_library=%{runtime_library_search_directories}"],
                ),
            ],
        ),
    ],
)

_uses_ifso_variables_feature = feature(
    name = _FEATURE_NAMES.uses_ifso_variables,
    enabled = True,
    flag_sets = [
        flag_set(
            actions = [ACTION_NAMES.cpp_link_dynamic_library],
            flag_groups = [
                flag_group(
                    expand_if_available = "generate_interface_library",
                    flags = ["--generate_interface_library_was_available"],
                ),
            ],
        ),
    ],
)

_def_feature = feature(
    name = _FEATURE_NAMES.def_feature,
    enabled = True,
    flag_sets = [
        flag_set(
            actions = [ACTION_NAMES.cpp_link_executable],
            flag_groups = [
                flag_group(
                    expand_if_available = "def_file_path",
                    flags = ["-qux_%{def_file_path}"],
                ),
            ],
        ),
    ],
)

_strip_debug_symbols_feature = feature(
    name = _FEATURE_NAMES.strip_debug_symbols,
    enabled = True,
    flag_sets = [
        flag_set(
            actions = [ACTION_NAMES.cpp_link_executable],
            flag_groups = [
                flag_group(
                    expand_if_available = "strip_debug_symbols",
                    flags = ["-strip_stuff"],
                ),
            ],
        ),
    ],
)

_feature_name_to_feature = {
    _FEATURE_NAMES.no_legacy_features: _no_legacy_features_feature,
    _FEATURE_NAMES.do_not_split_linking_cmdline: _do_not_split_linking_cmdline_feature,
    _FEATURE_NAMES.supports_dynamic_linker: _supports_dynamic_linker_feature,
    _FEATURE_NAMES.supports_interface_shared_libraries: _supports_interface_shared_libraries_feature,
    _FEATURE_NAMES.pic: _pic_feature,
    _FEATURE_NAMES.parse_headers: _parse_headers_feature,
    _FEATURE_NAMES.layering_check: _layering_check_feature,
    _FEATURE_NAMES.module_map_home_cwd: _module_map_home_cwd_feature,
    _FEATURE_NAMES.user_compile_flags: _user_compile_flags_feature,
    _FEATURE_NAMES.thin_lto: _thin_lto_feature,
    _FEATURE_NAMES.thin_lto_linkstatic_tests_use_shared_nonlto_backends: _thin_lto_linkstatic_tests_use_shared_nonlto_backends_feature,
    _FEATURE_NAMES.thin_lto_all_linkstatic_use_shared_nonlto_backends: _thin_lto_all_linkstatic_use_shared_nonlto_backends_feature,
    _FEATURE_NAMES.enable_afdo_thinlto: _enable_afdo_thinlto_feature,
    _FEATURE_NAMES.autofdo_implicit_thinlto: _autofdo_implicit_thinlto_feature,
    _FEATURE_NAMES.enable_fdo_thinlto: _enable_fdo_thin_lto_feature,
    _FEATURE_NAMES.fdo_implicit_thinlto: _fdo_implicit_thinlto_feature,
    _FEATURE_NAMES.enable_xbinaryfdo_thinlto: _enable_xbinaryfdo_thinlto_feature,
    _FEATURE_NAMES.xbinaryfdo_implicit_thinlto: _xbinaryfdo_implicit_thinlto_feature,
    _FEATURE_NAMES.autofdo: _autofdo_feature,
    _FEATURE_NAMES.is_cc_fake_binary: _is_cc_fake_binary_feature,
    _FEATURE_NAMES.xbinaryfdo: _xbinaryfdo_feature,
    _FEATURE_NAMES.fdo_optimize: _fdo_optimize_feature,
    _FEATURE_NAMES.fdo_instrument: _fdo_instrument_feature,
    _FEATURE_NAMES.per_object_debug_info: _per_object_debug_info_feature,
    _FEATURE_NAMES.copy_dynamic_libraries_to_binary: _copy_dynamic_libraries_to_binary_feature,
    _FEATURE_NAMES.supports_start_end_lib: _supports_start_end_lib_feature,
    _FEATURE_NAMES.supports_pic: _supports_pic_feature,
    _FEATURE_NAMES.targets_windows: _targets_windows_feature,
    _FEATURE_NAMES.compiler_param_file: _compiler_param_file_feature,
    _FEATURE_NAMES.module_maps: _module_maps_feature,
    _FEATURE_NAMES.static_link_cpp_runtimes: _static_link_cpp_runtimes_feature,
    _FEATURE_NAMES.simple_compile_feature: _simple_compile_feature,
    _FEATURE_NAMES.simple_link_feature: _simple_link_feature,
    _FEATURE_NAMES.link_env: _link_env_feature,
    _FEATURE_NAMES.static_linking_mode: _static_linking_mode_feature,
    _FEATURE_NAMES.dynamic_linking_mode: _dynamic_linking_mode_feature,
    _FEATURE_NAMES.objcopy_embed_flags: _objcopy_embed_flags_feature,
    _FEATURE_NAMES.ld_embed_flags: _ld_embed_flags_feature,
    _FEATURE_NAMES.fission_flags_for_lto_backend: _fission_flags_for_lto_backend_feature,
    _FEATURE_NAMES.min_os_version_flag: _min_os_version_flag_feature,
    _FEATURE_NAMES.include_directories: _include_directories_feature,
    _FEATURE_NAMES.from_package: _from_package_feature,
    _FEATURE_NAMES.absolute_path_directories: _absolute_path_directories_feature,
    _FEATURE_NAMES.change_tool: _change_tool_feature,
    _FEATURE_NAMES.module_map_without_extern_module: _module_map_without_extern_module_feature,
    _FEATURE_NAMES.foo: _foo_feature,
    _FEATURE_NAMES.library_search_directories: _library_search_directories_feature,
    _FEATURE_NAMES.runtime_library_search_directories: _runtime_library_search_directories_feature,
    _FEATURE_NAMES.generate_submodules: _generate_submodules_feature,
    _FEATURE_NAMES.uses_ifso_variables: _uses_ifso_variables_feature,
    _FEATURE_NAMES.def_feature: _def_feature,
    _FEATURE_NAMES.strip_debug_symbols: _strip_debug_symbols_feature,
    "header_modules_feature_configuration": _header_modules_feature_configuration,
    "env_var_feature_configuration": _env_var_feature_configuration,
    "host_and_nonhost_configuration": _host_and_nonhost_configuration,
    "simple_layering_check": _simple_layering_check_feature,
    "compilation_mode_features": _compilation_mode_features,
    "compile_header_modules": _compile_header_modules_feature_configuration,
}

_tool_for_action_config = {
    "objcopy_embed_data": "objcopy_embed_data_tool",
    "ld_embed_data": "ld_embed_data_tool",
}

def _get_features_for_configuration(name):
    f = _feature_name_to_feature[name]
    if f == None:
        fail("Feature not defined: " + name)
    if type(f) == type([]):
        return f
    else:
        return [f]

def _get_action_config(name, path):
    return action_config(
        action_name = name,
        enabled = True,
        tools = [tool(path = path)],
    )

def _get_artifact_name_pattern(category, prefix, extension):
    return artifact_name_pattern(
        category_name = category,
        prefix = prefix,
        extension = extension,
    )

def _get_tool_path(name, path):
    return tool_path(name = name, path = path)

def _impl(ctx):
    toolchain_identifier = ctx.attr.toolchain_identifier
    host_system_name = ctx.attr.host_system_name
    target_system_name = ctx.attr.target_system_name
    target_cpu = ctx.attr.cpu
    target_libc = ctx.attr.target_libc
    compiler = ctx.attr.compiler
    abi_version = ctx.attr.abi_version
    abi_libc_version = ctx.attr.abi_libc_version
    cc_target_os = ctx.attr.cc_target_os if ctx.attr.cc_target_os != "" else None
    builtin_sysroot = ctx.attr.builtin_sysroot if ctx.attr.builtin_sysroot != "" else None

    all_link_actions = [
        ACTION_NAMES.cpp_link_executable,
        ACTION_NAMES.cpp_link_dynamic_library,
        ACTION_NAMES.cpp_link_nodeps_dynamic_library,
    ]

    default_compile_flags_feature = feature(
        name = "default_compile_flags",
        enabled = True,
        flag_sets = [
            flag_set(
                actions = [
                    ACTION_NAMES.linkstamp_compile,
                    ACTION_NAMES.cpp_compile,
                    ACTION_NAMES.cpp_header_parsing,
                    ACTION_NAMES.cpp_module_compile,
                    ACTION_NAMES.cpp_module_codegen,
                    ACTION_NAMES.lto_backend,
                    ACTION_NAMES.clif_match,
                ],
                flag_groups = [flag_group(flags = ["--default-compile-flag"])],
            ),
        ],
    )

    default_link_flags_feature = feature(
        name = "default_link_flags",
        enabled = True,
        flag_sets = [
            flag_set(
                actions = all_link_actions,
                flag_groups = [flag_group(flags = ["-ldefault-link-flag"])],
            ),
        ],
    )

    features = [default_compile_flags_feature, default_link_flags_feature]

    should_add_multiple_tools_action_config = False

    for name in ctx.attr.feature_names:
        if name == _FEATURE_NAMES.change_tool:
            should_add_multiple_tools_action_config = True

        features.extend(_get_features_for_configuration(name))

    cxx_builtin_include_directories = ["/usr/lib/gcc/", "/usr/local/include", "/usr/include"]

    for directory in ctx.attr.cxx_builtin_include_directories:
        cxx_builtin_include_directories.append(directory)

    artifact_name_patterns = []

    for category, values in ctx.attr.artifact_name_patterns.items():
        artifact_name_patterns.append(_get_artifact_name_pattern(category, values[0], values[1]))

    action_configs = []

    for name in ctx.attr.action_configs:
        action_configs.append(
            _get_action_config(name, _tool_for_action_config.get(name, default = "DUMMY_TOOL")),
        )
    if should_add_multiple_tools_action_config:
        action_configs.append(_multiple_tools_action_config)

    make_variables = [
        make_variable(name = name, value = value)
        for name, value in ctx.attr.make_variables.items()
    ]

    if ctx.attr.tool_paths == {}:
        tool_paths = [
            tool_path(name = "ar", path = "/usr/bin/mock-ar"),
            tool_path(
                name = "compat-ld",
                path = "/usr/bin/mock-compat-ld",
            ),
            tool_path(name = "cpp", path = "/usr/bin/mock-cpp"),
            tool_path(name = "dwp", path = "/usr/bin/mock-dwp"),
            tool_path(name = "gcc", path = "/usr/bin/mock-gcc"),
            tool_path(name = "gcov", path = "/usr/bin/mock-gcov"),
            tool_path(name = "ld", path = "/usr/bin/mock-ld"),
            tool_path(name = "nm", path = "/usr/bin/mock-nm"),
            tool_path(name = "objcopy", path = "/usr/bin/mock-objcopy"),
            tool_path(name = "objdump", path = "/usr/bin/mock-objdump"),
            tool_path(name = "strip", path = "/usr/bin/mock-strip"),
            tool_path(
                name = "llvm-profdata",
                path = "/usr/bin/mock-llvm-profdata",
            ),
        ]
    else:
        tool_paths = [_get_tool_path(name, path) for name, path in ctx.attr.tool_paths.items()]

    out = ctx.actions.declare_file(ctx.label.name)
    ctx.actions.write(out, "Fake executable")
    return [
        cc_common.create_cc_toolchain_config_info(
            ctx = ctx,
            features = features,
            action_configs = action_configs,
            artifact_name_patterns = artifact_name_patterns,
            cxx_builtin_include_directories = cxx_builtin_include_directories,
            toolchain_identifier = toolchain_identifier,
            host_system_name = host_system_name,
            target_system_name = target_system_name,
            target_cpu = target_cpu,
            target_libc = target_libc,
            compiler = compiler,
            abi_version = abi_version,
            abi_libc_version = abi_libc_version,
            tool_paths = tool_paths,
            make_variables = make_variables,
            builtin_sysroot = builtin_sysroot,
            cc_target_os = cc_target_os,
        ),
        DefaultInfo(
            executable = out,
        ),
    ]

cc_toolchain_config = rule(
    implementation = _impl,
    attrs = {
        "cpu": attr.string(default = "k8"),
        "compiler": attr.string(default = "compiler"),
        "toolchain_identifier": attr.string(default = "mock-llvm-toolchain-k8"),
        "host_system_name": attr.string(default = "local"),
        "target_system_name": attr.string(default = "local"),
        "target_libc": attr.string(default = "local"),
        "abi_version": attr.string(default = "local"),
        "abi_libc_version": attr.string(default = "local"),
        "feature_names": attr.string_list(),
        "action_configs": attr.string_list(),
        "artifact_name_patterns": attr.string_list_dict(),
        "cc_target_os": attr.string(),
        "builtin_sysroot": attr.string(default = "/usr/grte/v1"),
        "tool_paths": attr.string_dict(),
        "cxx_builtin_include_directories": attr.string_list(),
        "make_variables": attr.string_dict(),
    },
    provides = [CcToolchainConfigInfo],
    executable = True,
)
